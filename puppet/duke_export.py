#==============================================================================#
# Duke University                                                              #
# K. P. Trofatter                                                              #
# kpt2@duke.edu                                                                #
#==============================================================================#
# Duke Export - Blender add-on
#
# Exports selected armature and active animation data to MATLAB Puppet library.
# A 'Duke Export' panel is added to the 3D-View screen properties region. The
# panel contains controls to selectively enable output, choose output files,
# and execute the export operation.
#
# Puppet data comprises a subset of material, mesh object, and armature data.
# Information needed to reproduce Shape Key and Skeleton Subspace deformation
# are exported. Also, custom material properties prepended with 'duke_' are
# exported, and allow scalar physical properties to be assigned to mesh faces.
# Details can be found in the MATLAB PuppetREADME.m script.
#
# INSTALLATION:
#   1) open Blender
#   2) open User Preferences [Ctrl + Alt + U]
#   3) go to the add-on tab
#   4) click on the "Install Add-on from File..." button
#   5) select the 'duke_export.py' file
#   6) check the box next to the "Import-Export: Duke Export" add-on header
#
# NOTE : names have spaces and periods replaced with underscores when exporting!

# import
import bpy
from bpy.props import (BoolProperty, StringProperty, PointerProperty)


# add-on metadata
bl_info = {
    'name'        : 'Duke Export',
    'author'      : 'K. P. Trofatter',
    'version'     : (1, 0, 0),
    'blender'     : (2, 7, 9),
    'support'     : 'COMMUNITY',
    'category'    : 'Import-Export',
    'description' :
        'Exports armature and animation data to MATLAB Puppet library.',
    'location'    : 'View 3D > Object Mode > Properties',
    'warning'     : '',
    'wiki_url'    : '',
    'tracker_url' : ''
    }


# add-on data
class DukeData(bpy.types.PropertyGroup):
    
    # create puppet export enable
    puppet_enable = BoolProperty(
        name='export puppet enable',
        description='export puppet enable',
        default=True
        )
    
    # create puppet export path
    puppet_path = StringProperty(
        name='puppet export path',
        description='export puppet path',
        default='puppet.txt',
        subtype='FILE_PATH'
        )
    
    # create animation export enable
    animation_enable = BoolProperty(
        name='export animation enable',
        description='export animation enable',
        default=True
        )
    
    # create animation export path
    animation_path = StringProperty(
        name='export animation path',
        description='export animation path',
        default='animation.txt',
        subtype='FILE_PATH'
        )


# ui panel
class DukeExportPanel(bpy.types.Panel):
    
    # attributes
    bl_label = 'Duke Export'
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    
    
    # poll context for selected armature
    @classmethod
    def poll(self, context):
        return context.object and context.object.type == 'ARMATURE'
    
    
    # draw panel
    def draw(self, context):
        
        # notation
        layout = self.layout
        scene = context.scene
        
        # widget : export button
        layout.operator('duke.export', text='Export', icon='EXPORT')
        
        # puppet controls row
        row = layout.row(align=False)
        
        # widget : export puppet enable
        row.prop(scene.duke, 'puppet_enable', icon='ARMATURE_DATA', text='')
        
        # widget : export puppet path
        row.prop(scene.duke, 'puppet_path', text='')
        
        # animation controls row
        row = layout.row(align=False)
        
        # widget : export animation enable
        row.prop(scene.duke, 'animation_enable', icon='ANIM', text='')
        
        # widget : export animation path
        row.prop(scene.duke, 'animation_path', text='')


# export button
class DukeExportButton(bpy.types.Operator):
    
    # attributes
    bl_idname = 'duke.export'
    bl_label = 'Duke Export'
    
    
    # rename for export
    def rename(self, name):
        return name.replace(' ', '_').replace('.', '_')
    
    
    # write material
    def write_material(self, f, material):
        
        # write material type
        f.write('type : material\n')
            
        # write material name
        f.write('name : ' + self.rename(material.name) + '\n')
        
        # write number of custom properties
        keys = material.id_data.keys()
        n = sum(k.find('duke_', 0, 5) is not -1 for k in keys)
        f.write('properties : ' + str(n) + '\n')
        
        # write material custom properties
        for k in keys:
            
            # continue if not duke property
            if k.find('duke_', 0, 5) is -1:
                continue
            
            # write property name-value pair
            name = k.replace('duke_', '')
            value = material.id_data[k]
            f.write(self.rename(name) + ' : ' + str(value) + '\n')
        
        # write blank
        f.write('\n')
    
    
    # write matrix
    def write_matrix(self, f, matrix):
        
        f.write(str(matrix[0][0]) + ' ')
        f.write(str(matrix[1][0]) + ' ')
        f.write(str(matrix[2][0]) + ' ')
        f.write(str(matrix[0][1]) + ' ')
        f.write(str(matrix[1][1]) + ' ')
        f.write(str(matrix[2][1]) + ' ')
        f.write(str(matrix[0][2]) + ' ')
        f.write(str(matrix[1][2]) + ' ')
        f.write(str(matrix[2][2]) + ' ')
        f.write(str(matrix[0][3]) + ' ')
        f.write(str(matrix[1][3]) + ' ')
        f.write(str(matrix[2][3]) + '\n')
    
    
    # write vertex coordinates
    def write_vertices(self, f, vertices):
        
        for v in vertices:
            
            f.write(str(v.co.x) + ' ')
            f.write(str(v.co.y) + ' ')
            f.write(str(v.co.z) + '\n')
    
    
    # write vertex data (excludes coordinates, which are in shape types)
    def write_vertex_data(self, f, vertices):
        
        # write vertex type
        f.write('type : vertex\n')
        
        for vertex in vertices:
            
            # write color
            # TODO, but not really needed...
            
            # write normal
            f.write(str(vertex.normal.x) + ' ')
            f.write(str(vertex.normal.y) + ' ')
            f.write(str(vertex.normal.z) + '\n')
            
            # write uv
            # TODO, but not really needed...
            
        # write blank
        f.write('\n')
    
    
    # write face data
    def write_face_data(self, f, faces, materials):
        
        # write face type
        f.write('type : face\n')
        
        # write max ngon
        n = max(len(face.vertices) for face in faces)
        f.write('ngon : ' + str(n) + '\n')
        
        for face in faces:
            
            # write face vertex indices
            for vertex in face.vertices:
                
                f.write(str(vertex) + ' ')
            
            # write trailing dummy indices
            for i in range(0, n - len(face.vertices)):
                
                f.write('-1 ')
                
            # write delimiter
            f.write(',')
            
            # write (global) material index
            name = materials[face.material_index].name
            for i in range(0, len(bpy.data.materials)):
                if name == bpy.data.materials[i].name:
                    break
            f.write(str(i) + '\n')
            
        # write blank
        f.write('\n')
    
    
    # write mesh
    def write_mesh(self, f, mesh):
        
        # write mesh type
        f.write('type : mesh\n')
        
        # write name
        f.write('name : ' + self.rename(mesh.name) + '\n')
        
        # write visibility
        f.write('visible : ' + str(not mesh.hide) + '\n')
        
        # write pose (puppet coordinates)
        f.write('pose : ')
        self.write_matrix(f, mesh.matrix_local)
        
        # count shapes
        try:
            
            # shape keys
            n = len(mesh.data.shape_keys.key_blocks)
            keys = True
            
        except:
            
            # no shape keys, just a base mesh (equivalent to a single key)
            n = 1
            keys = False
        
        # write number of shape keys
        f.write('shapes : ' + str(n) + '\n')
        
        # write number of vertices
        n = len(mesh.data.vertices)
        f.write('vertices : ' + str(n) + '\n')
        
        # write number of faces
        n = len(mesh.data.polygons)
        f.write('faces : ' + str(n) + '\n')
        
        # write blank
        f.write('\n')
        
        # write shapes
        if keys:
            
            # write keys
            for shape in mesh.data.shape_keys.key_blocks:
                
                # write shape type
                f.write('type : shape\n')
                
                # write name
                f.write('name : ' + self.rename(shape.name) + '\n')
                
                # write vertex coordinates
                self.write_vertices(f, shape.data)
                
                # write blank
                f.write('\n')
                
        else:
            
            # write base mesh
            f.write('type : shape\n')
            
            # write name
            f.write('name : ' + self.rename(mesh.name) + '\n')
            
            # write vertices
            self.write_vertices(f, mesh.data.vertices)
            
            # write blank
            f.write('\n')
        
        # write vertex data (excludes coordinates, which are in shape types)
		# DISABLED
        #self.write_vertex_data(f, mesh.data.vertices)
        
        # write face data
        self.write_face_data(f, mesh.data.polygons, mesh.data.materials)
        
    
    # write kinship
    def write_kinship(self, f, bone, armature):
        
        # write parent
        if bone.parent and bone.parent.bone.use_deform:
            
            # parent exists
            f.write('parent : ' + self.rename(bone.parent.name) + '\n')
            
        else:
            
            # no parent bone, so make it a child of the armature
            f.write('parent : ' + self.rename(armature.name) + '\n')
        
        # write children
        n = sum(b.bone.use_deform for b in bone.children)
        if n:
            
            # write number of children
            f.write('children : ' + str(n) + '\n')
            
            # write list of children
            for i in range(0, len(bone.children)):
                if bone.children[i].bone.use_deform:
                    f.write(' ' + self.rename(bone.children[i].name))
            f.write('\n')
            
        else:
            
            # no children
            f.write('children : 0\n')
    
    
    # write bone
    def write_bone(self, f, bone, armature):
        
        # skip if not deformation bone
        # may unlink part of parent-child graph, set parent to arm ature?
        if not bone.bone.use_deform:
            return
        
        # write type
        f.write('type : bone\n')
        
        # write name
        f.write('name : ' + self.rename(bone.name) + '\n')
        
        # write parent and children
        self.write_kinship(f, bone, armature)
        
        # write bone rest pose (object coordinates)
        f.write('pose : ')
        self.write_matrix(f, bone.bone.matrix_local)
        
        # write blank
        f.write('\n')
        
        # write weight groups
        for c in armature.children:
            
            # verify child is a mesh
            if c.type != 'MESH':
                continue
            
            # write type
            f.write('type : weights\n')
            
            # write mesh name
            f.write('name : ' + self.rename(c.name) + '\n')
            
            # write weights
            try:
                
                # write number of weights
                i = c.vertex_groups[bone.name].index
                n = sum(g.group == i for v in c.data.vertices for g in v.groups)
                f.write('weights : ' + str(n) + '\n')
                
                # write weight group indices and values
                bone_vertex_group_index = c.vertex_groups[bone.name].index
                for i, v in enumerate(c.data.vertices):
                    for g in v.groups:
                        if g.group == bone_vertex_group_index:
                            f.write(str(i) + ' ' + str(g.weight) + '\n')
                
            except:
                
                # no weights
                f.write('weights : 0\n')
            
            # write blank
            f.write('\n')
    
    
    # write puppet
    def write_puppet(self, scene, armature, bones):
        
        # get parameters
        puppet_path = scene.duke['puppet_path']
        
        with open(puppet_path, 'w') as f:
            
            # write type
            f.write('type : puppet\n')
            
            # write object name
            f.write('name : ' + self.rename(armature.name) + '\n')
            
            # write number of materials
            n = len(bpy.data.materials)
            f.write('materials : ' + str(n) + '\n')
            
            # write number of meshes
            n = sum(c.type == 'MESH' for c in armature.children)
            f.write('meshes : ' + str(n) + '\n')
            
            # write number of deformation bones
            n = sum(b.bone.use_deform for b in bones)
            f.write('bones : ' + str(n) + '\n')
            
            # write blank
            f.write('\n')
            
            # write materials
            for m in bpy.data.materials:
                self.write_material(f, m)
            
            # write meshes
            for c in armature.children:
                
                # check child is mesh
                if c.type != 'MESH':
                    continue
                
                # write mesh
                self.write_mesh(f, c)
            
            # write bones
            for b in bones:
                self.write_bone(f, b, armature)
    
    
    # write animation
    def write_animation(self, scene, armature, bones):
        
        # get parameters
        animation_path = scene.duke['animation_path']
        
        with open(animation_path, 'w') as f:
            
            # write type
            f.write('type : animation\n')
            
            # write animation name
            f.write('name : ' + self.rename(scene.name) + '\n')
            
            # write puppet name
            f.write('puppet : ' + self.rename(armature.name) + '\n')
            
            # write number of meshes
            nmeshes = sum(c.type == 'MESH' for c in armature.children)
            f.write('meshes : ' + str(nmeshes) + '\n')
            
            # write number of bones
            nbones = sum(b.bone.use_deform for b in bones)
            f.write('bones : ' + str(nbones) + '\n')
            
            # write number of frames
            nframes = scene.frame_end - scene.frame_start + 1
            f.write('frames : ' + str(nframes) + '\n')
            
            # write blank
            f.write('\n')
            
            # write puppet pose type
            f.write('type : puppet\n')
            
            # write puppet name
            f.write('name : ' + self.rename(armature.name) + '\n')
            
            # cache animation data (efficiently updates scene only once)
            armature_pose = [None] * nframes
            meshes_pose = [None] * nframes
            bones_pose = [None] * nframes
            for i in range(scene.frame_start, scene.frame_end + 1):
            
                # set scene frame
                scene.frame_set(i)
                scene.update()
                
                # get pose
                armature_pose[i] = armature.matrix_world.copy()
                
                # get mesh pose (w.r.t. puppet)
                meshes_pose[i] = [None] * nmeshes
                j = 0
                for c in armature.children:
                    
                    # check for meshes
                    if c.type == 'MESH':
                        
                        # get pose
                        meshes_pose[i][j] = c.matrix_local.copy()
                        j += 1
                
                # get bone pose (w.r.t. puppet)
                bones_pose[i] = [None] * nbones
                j = 0
                for b in bones:
                    
                    # check for deformation bones
                    if b.bone.use_deform:
                        
                        # get pose
                        bones_pose[i][j] = b.matrix.copy()
                        j += 1
            
            # write armature pose (w.r.t. world)
            for i in range(scene.frame_start, scene.frame_end + 1):
                self.write_matrix(f, armature_pose[i])
            
            # write blank
            f.write('\n')
            
            # write mesh pose (w.r.t. puppet)
            j = 0
            for c in armature.children:
                
                # check for meshes
                if c.type == 'MESH':
                    
                    # write mesh type
                    f.write('type : mesh\n')
                    
                    # write mesh name
                    f.write('name : ' + self.rename(c.name) + '\n')
                    
                    # write mesh track
                    for i in range(scene.frame_start, scene.frame_end + 1):
                        
                        # write pose
                        self.write_matrix(f, meshes_pose[i][j])
                    
                    # increment
                    j += 1
                    
                    # write blank
                    f.write('\n')
            
            # write bone pose animation
            j = 0
            for b in bones:
                
                # check for deformation bones
                if b.bone.use_deform:
                
                    # write type
                    f.write('type : bone\n')
                    
                    # write name
                    f.write('name : ' + self.rename(b.name) + '\n')
                    
                    # write bone track
                    for i in range(scene.frame_start, scene.frame_end + 1):
                        
                        # write pose
                        self.write_matrix(f, bones_pose[i][j])
                    
                    # increment
                    j += 1
                    
                    # write blank
                    f.write('\n')
    
    
    # button action
    def execute(self, context):
        
        # notation
        scene = context.scene
        armature = context.object
        bones = armature.pose.bones
        
        # write puppet (meshes, shape keys, bones, weights)
        if scene.duke['puppet_enable']:
            self.write_puppet(scene, armature, bones)
        
        # write animation (animated pose data for armature, bones, meshes)
        if scene.duke['animation_enable']:
            
            # stash current frame
            frame = scene.frame_current
            
            # write animation
            self.write_animation(scene, armature, bones)
            
            # recall current frame
            scene.frame_current = frame
            scene.update()
        
        return {'FINISHED'}


# register add-on
def register():
    
    # register
    bpy.utils.register_module(__name__)
    
    # create ui data structure
    bpy.types.Scene.duke = PointerProperty(type=DukeData)


# unregister add-on
def unregister():
    
    # delete ui data structure
    del bpy.types.Scene.duke
    
    # unregister
    bpy.utils.unregister_module(__name__)


# script
if __name__ == '__main__':
    register()


#==============================================================================#
#                                                                              #
#                                                                              #
#                                                                              #
#==============================================================================#
