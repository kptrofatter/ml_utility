% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% Puppet*() - library for modeling deformable geometry.
%
% The motivation for the puppet library is two fold; to facilitate the creation
% of high quality animated scenes needed in modern simulations, and to form an
% integral part of stiching image sets of deformable objects.
%
% Blender's advanced tools are used to model, paint, rig, skin, and animate
% mesh geometry. Armature and animation data are exported using the custom
% "duke_export.py" add-on.
%
% Data is imported into MATLAB as a puppet and animation structure. Puppets are
% posed with animation data (or by future research!). Vertices are deformed by
% Shape Key Deformation (SKD) and Skeletal Subspace Deformation (SSD). Material
% properties are computed per-vertex. Getting vertex and material property data
% collects results into a simple format suitable for easy simulation.
%
% To enable diffraction limited surfaces, geomtery can also be refined such that
% no face has an edge longer than a given distance.
%
% To enable volumetric stitching of a moving target, "cactus hairs" of vertices
% can be added at mesh vertices along the average normal of adjacent faces.
%
% All functions except the scans and pose functions respect mesh visibility when
% operating on a puppet. Meshes with their 'visible' flag set are operated upon,
% while meshes with the flag reset are bypassed. This feature is to selectively
% enable geometry when simulating and stitching, and to speed up computation if
% because MATLAB can be quite pokey even for these simple algorithms.

% example =====================================================================%

% environment
close('all');
clear();
clc();

% scan
puppet = PuppetScan('puppet.txt');
anim   = PuppetAnimScan('animation.txt');

% pose
puppet = PuppetPose(puppet, anim, 60);

% get results
verts  = PuppetGet(puppet, 'vertices');
sigma  = PuppetGet(puppet, 'reflectivity');

% draw
[~, ah] = PuppetDraw([], puppet, 'reflectivity');
title(ah, 'Puppet');

% hide puppet body mesh
hidden = PuppetVisibility(puppet, [0, 1, 1, 1]);
[~, ah] = PuppetDraw([], hidden);
title(ah, 'Hidden');

% change puppet material
mutant = puppet;
mutant.materials(5).duke.reflectivity = 0.1;
mutant = PuppetSample(mutant);
[~, ah] = PuppetDraw([], mutant, 'reflectivity', 'nfb');
colorbar('peer', ah);
title(ah, 'Mutant');

% grow cactus hairs on puppet
cactus = PuppetCactus(puppet, [-0.02, 0.02]);
[~, ah] = PuppetDraw([], cactus);
title(ah, 'Cactus');

% refine puppet geometry
refine = PuppetRefine(puppet, 0.03);
[~, ah] = PuppetDraw([], refine);
title(ah, 'Refine');


% puppet functions ============================================================%

% io
% [puppet] = PuppetScan(path)                % scan puppet data
% [anim]   = PuppetAnimScan(path)            % scan puppet animation data

% modify
% [puppet] = PuppetRefine(puppet, delta)     % refine meshes
% [puppet] = PuppetCactus(puppet, profile)   % grow "cactus hair" on meshes

% animate
% [puppet] = PuppetPose(puppet, anim, frame) % pose puppet with animation data

% update
% [puppet] = PuppetDeform(puppet)            % compute posed puppet vertices
% [puppet] = PuppetSample(puppet)            % compute pervertex material data

% data
% [data]   = PuppetGet(puppet, name)         % get combined puppet data
% [puppet] = PuppetVisibility(puppet, flags) % set mesh visibility flags quickly

% draw
% [gh, ah] = PuppetDraw(ah, puppet, name, mask, alpha) % draw puppet to an axis


% global variables ============================================================%

% animation playback structure
% not required, but possibly useful for time-based shape key weight drivers
% [1,1] struct  | PLAYBACK    | animation playback structure
% [1,1] double  | .frame      | current frame
% [1,1] double  | .nframes    | total number of frames


% puppet structure ============================================================%

% [1,1] struct  | puppet      | puppet structure
% [1,?] char    | .name       | puppet name
% [1,1] struct  | .A          | puppet pose (w.r.t world)
% [3,3] double  |  .M         | pose transformation matrix
% [3,1] double  |  .v         | pose translation vector
% [1,n] struct  | .materials  | puppet materials
% [1,?] char    |  .name      | material name
% [1,1] struct  |  .duke      | material custom properties
% [?,?] ???     |   .???      | material custom property
% [1,m] struct  | .meshes     | puppet meshes
% [1,?] char    |  .name      | mesh name
% [1,1] logical |  .visible   | mesh visibility flag
% [1,1] struct  |  .A_rest    | mesh rest pose (w.r.t. puppet)
% [1,1] struct  |  .A         | mesh pose (w.r.t. puppet)
% [1,s] struct  |  .shapes    | mesh shape keys
% [1,?] char    |   .name     | shape key name
% [3,v] double  |   .vertices | shape key vertex data (w.r.t. puppet)
% [1,?] ???     |   .weight   | shape key weight (double, function)
% [1,v] double  |  .vertices  | mesh evaluated vertices
% [3,f] double  |  .faces     | mesh face vertex indices (triangulated)
% [1,f] double  |  .materials | mesh face material indices
% [1,1] struct  |  .duke      | mesh custom pervertex properties
% [?,?] ???     |   .???      | mesh custom pervertex property
% [1,b] struct  | .bones      | puppet deformation skeleton
% [1,?] char    |  .name      | bone name
% [1,?] char    |  .parent    | bone parent name
% [1,c] cell    |  .children  | bone children names
% [1,1] struct  |  .A_rest    | bone rest pose (w.r.t. puppet)
% [1,1] struct  |  .A         | bone pose (w.r.t. puppet)
% [1,m] cell    |  .indices   | bone mesh vertex indices ([1,w] double)
% [1,m] cell    |  .weights   | bone mesh vertex weights ([1,w] double)


% puppet animation structure ==================================================%

% [1,1] struct  | animation   | puppet animation structure
% [1,?] char    | .name       | puppet animation name
% [1,?] char    | .puppet     | puppet name
% [1,f] struct  | .A          | puppet pose (w.r.t world)
% [3,3] double  |  .M         | pose transformation matrix
% [3,1] double  |  .v         | pose translation vector
% [1,m] struct  | .meshes     | puppet meshes poses
% [1,?] char    |  .name      | mesh name
% [1,f] struct  |  .A         | mesh poses (w.r.t. puppet)
% [1,b] struct  | .bones      | puppet bones poses
% [1,?] char    |  .name      | bone name
% [1,f] struct  |  .A         | bone poses (w.r.t. puppet)


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
