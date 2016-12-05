%==============================================================================%
% ???                                                          Duke University %
%                                                              K. P. Trofatter %
% utility/???/                                                   kpt2@duke.edu %
%==============================================================================%
% ???() description
%
% USAGE:
%   [] = ???()
% INPUT:
% OUTPUT:

%% =============================================================================
%% =============================================================== [DO NOT EDIT]
%==============================================================================%
%                                                                              %
%==============================================================================%
%%
%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%


%% Data structure paradigms in MATLAB ==========================================

%
%            Single    Multi  ELEMENT INDEX
% Single     Scalar    Vector
% Multi      Grid      Array
% SET INDEX

%   Sn(i)   <=>   V(n,i)
%
%     ^              ^
%     |              |
%
%  Gn(i,j,k) <=> A(n,i,j,k)

% To map S -> G or V ->A extra information about the size of G or A is required.

% Note, clould have cells of S or G, but serve no benefit over V or A

% If given single element indexed variables
%  if returning multiple
%    Return same type
%  if returning single
%    Return multiple type
% If given a vector
%  if returning multiple
%  if returning single



%% Scalar ======================================================================
% + Used by MATLAB
% + Supports arbitrary list of points (good for sparsity)
% + Explicit interpretation
% - Clutters namespace quickly
% - Logically single unit split into parts

% SET OF ROW VECTORS OF SCALARS
% + Same shape as returned by : and linspace
% - First index unused
X = [1 2 3 4 5];
Y = [1 2 3 4 5];
Z = [1 2 3 4 5];

% SET OF COLUMN VECTORS OF SCALARS
% + Only first index used
% - Does not play well with MATLAB
X = [1 2 3 4 5].';
Y = [1 2 3 4 5].';
Z = [1 2 3 4 5].';

%% Grid ========================================================================
% GENERALIZATION OF SCALAR
% + Used by MATLAB
% + Supports exhaustive lists of points (good for fields)
% + Explicit interpretation
% - Clutters namespace quickly
% - Logically single unit split into parts
[X,Y,Z] = ndgrid(x,y,z);

%% Structs =====================================================================
% + Single variable scalars and grids
% - Not used by MATLAB

% Scalar and grid struct
% + Explicit interpretation
% - Not extensible
s.X = X;
s.Y = Y;
s.Z = Z;

% Grid struct
% + Extensible
% - Implicit interpretation
s(1).X = X;
s(2).X = Y;
s(3).X = Z;

%% Cells =======================================================================
% + Single variable scalars and grids
% + Extensible
% - Not used by MATLAB
% - Implicit interpretation
c = {X,Y,Z};





%% Vector ======================================================================
% + Supports arbitrary list of points (good for sparsity)
% + Single variable
% - Not used by MATLAB

% MATRIX OF COLUMN VECTORS
% + Allows easy application of matrix multiplication
V = [...
    1 2 3 4 5;...
    1 2 3 4 5;...
    1 2 3 4 5 ...
];

% MATRIX OF ROW VECTORS
% - Does not offer any math benefits
V = [...
    1 1 1;...
    2 2 2;...
    3 3 3;...
    4 4 4;...
    5 5 5 ...
];

%% Array =======================================================================
% GENERALIZATION OF VECTOR
% + Supports exhaustive lists of points (good for fields)
% + Single variable
% - Implict interpretation
% - Memory intensive

% DATA FIRST ARRAY
A(:,m,n,...) = [1 2 3];

or 

% DATA LAST ARRAY
% - Must reshape data to use it
A(m,n,...,:) = [1 2 3];



% Strategy
% Write code to apply vector operations to 






