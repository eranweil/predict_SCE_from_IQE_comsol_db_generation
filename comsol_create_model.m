import com.comsol.model.*
import com.comsol.model.util.*

comsolRoot = 'C:\Program Files\COMSOL\COMSOL61\Multiphysics';   % <-- adjust
addpath(fullfile(comsolRoot, 'mli'));

% Try to start COMSOL server, but ignore "Already connected" errors
try
    mphstart;
catch ME
    if ~contains(ME.message, 'Already connected')
        rethrow(ME);
    end
end

showing_progress = ModelUtil.showProgress(true); % Progress window

model = ModelUtil.create('Model');

% Results and comsol model base directory
model.hist.disable
model.modelPath(strcat(base_directory,'comsol'));
model.label('basic_diode_model_basic_features.mph');

% Add parameters
comsol_func_parameter_set;
model.component.create('comp1', true);

% Add list of locations for dirac deltas (based on
% comsol_func_set_delta_list script
model.component('comp1').curvedInterior(false);
comsol_func_set_delta_list;

% Add model geometry
model.component('comp1').geom.create('geom1', 1);
comsol_func_geometry;

% Add tables of optical coefficients
comsol_func_set_tables_per_lambda;
comsol_func_variables;

% Add model mesh
model.component('comp1').mesh.create('mesh1');
comsol_func_mesh_creation;

% Add material attributes
model.component('comp1').material.create('mat1', 'Common');
comsol_func_material;

% Add physics
model.component('comp1').physics.create('semi', 'Semiconductor', 'geom1');
comsol_func_physics;

model.component('comp1').view('view1').axis.set('xmin', -5);
model.component('comp1').view('view1').axis.set('xmax', 105);

% Study 1: Background lighting sweep over lambda
model.study.create('std1');
model.study('std1').create('stat', 'Stationary');
model.study('std1').feature('stat').set('useadvanceddisable', true);
model.study('std1').feature('stat').set('disabledvariables', {'var2' 'var4'});

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('p1', 'Parametric');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').create('d1', 'Direct');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.study('std1').label('Study 1 only bg lighting');
model.study('std1').feature('stat').set('useparam', true);
model.study('std1').feature('stat').set('sweeptype', 'filled');
model.study('std1').feature('stat').set('pname', {'Lambda0'});
model.study('std1').feature('stat').set('plistarr', {'range(250,25,1225)'});
model.study('std1').feature('stat').set('punit', {'nm'});

model.sol('sol1').attach('std1');
model.sol('sol1').feature('v1').set('clistctrl', {'p1'});
model.sol('sol1').feature('v1').set('cname', {'Lambda0'});
model.sol('sol1').feature('v1').set('clist', {'range(250,25,1225)[nm]'});
model.sol('sol1').feature('s1').set('stol', 1.0E-6);
model.sol('sol1').feature('s1').set('probesel', 'none');
model.sol('sol1').feature('s1').feature('aDef').set('cachepattern', true);
model.sol('sol1').feature('s1').feature('p1').set('sweeptype', 'filled');
model.sol('sol1').feature('s1').feature('p1').set('pname', {'Lambda0'});
model.sol('sol1').feature('s1').feature('p1').set('plistarr', {'range(250,25,1225)'});
model.sol('sol1').feature('s1').feature('p1').set('punit', {'nm'});
model.sol('sol1').feature('s1').feature('p1').set('porder', 'constant');
model.sol('sol1').feature('s1').feature('fc1').set('initstep', 0.1);
model.sol('sol1').feature('s1').feature('fc1').set('minsteprecovery', 0.001);
model.sol('sol1').feature('s1').feature('fc1').set('maxiter', 50);
model.sol('sol1').feature('s1').feature('d1').set('ooc', false);
model.sol('sol1').feature('s1').feature('d1').set('errorchk', false);
model.sol('sol1').runAll;

% Study 2: No generation for Green model dark carrier concentration
if run_study_2
    model.study.create('std4');
    model.study('std4').create('stat', 'Stationary');
    model.study('std4').feature('stat').set('useadvanceddisable', true);
    model.study('std4').feature('stat').set('disabledvariables', {'var2' 'var3'});

    model.sol.create('sol4');
    model.sol('sol4').study('std4');
    model.sol('sol4').attach('std4');
    model.sol('sol4').create('st1', 'StudyStep');
    model.sol('sol4').create('v1', 'Variables');
    model.sol('sol4').create('s1', 'Stationary');
    model.sol('sol4').feature('s1').create('fc1', 'FullyCoupled');
    model.sol('sol4').feature('s1').create('d1', 'Direct');
    model.sol('sol4').feature('s1').feature.remove('fcDef');

    model.result.dataset.create('dset4', 'Solution');
    model.result.dataset('dset4').set('solution', 'sol4');

    model.study('std4').label('Study 2 no bg lighting');

    model.sol('sol4').attach('std4');
    model.sol('sol4').feature('st1').label('Compile Equations: Stationary');
    model.sol('sol4').feature('v1').label('Dependent Variables 1.1');
    model.sol('sol4').feature('s1').label('Stationary Solver 1.1');
    model.sol('sol4').feature('s1').set('stol', 1.0E-6);
    model.sol('sol4').feature('s1').feature('dDef').label('Direct 2');
    model.sol('sol4').feature('s1').feature('aDef').label('Advanced 1');
    model.sol('sol4').feature('s1').feature('aDef').set('cachepattern', true);
    model.sol('sol4').feature('s1').feature('aDef').set('assemtol', 0);
    model.sol('sol4').feature('s1').feature('fc1').label('Fully Coupled 1.1');
    model.sol('sol4').feature('s1').feature('fc1').set('initstep', 0.1);
    model.sol('sol4').feature('s1').feature('fc1').set('minsteprecovery', 0.001);
    model.sol('sol4').feature('s1').feature('fc1').set('maxiter', 50);
    model.sol('sol4').feature('s1').feature('d1').label('Direct 1.1');
    model.sol('sol4').feature('s1').feature('d1').set('ooc', false);
    model.sol('sol4').feature('s1').feature('d1').set('errorchk', false);
    model.sol('sol4').runAll;
end

% Study 3: Delta G sweep over locations loc0 in the device
model.study.create('std3');
model.study('std3').create('stat', 'Stationary');
model.study('std3').feature('stat').set('useadvanceddisable', true);
model.study('std3').feature('stat').set('disabledvariables', {'var3' 'var4'});

model.sol.create('sol3');
model.sol('sol3').study('std3');
model.sol('sol3').attach('std3');
model.sol('sol3').create('st1', 'StudyStep');
model.sol('sol3').create('v1', 'Variables');
model.sol('sol3').create('s1', 'Stationary');
model.sol('sol3').feature('s1').create('p1', 'Parametric');
model.sol('sol3').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol3').feature('s1').create('d1', 'Direct');
model.sol('sol3').feature('s1').feature.remove('fcDef');

model.result.dataset.create('dset3', 'Solution');
model.result.dataset('dset3').set('solution', 'sol3');

model.study('std3').label('Study 3 full sweep');
model.study('std3').feature('stat').set('useparam', true);
model.study('std3').feature('stat').set('pname', {'loc0'});
model.study('std3').feature('stat').set('plistarr', {'delta_list({range(1,1,number_of_deltas)})'});
model.study('std3').feature('stat').set('punit', {'um'});

model.sol('sol3').attach('std3');
model.sol('sol3').feature('v1').set('clistctrl', {'p1'});
model.sol('sol3').feature('v1').set('cname', {'loc0'});
model.sol('sol3').feature('v1').set('clist', {'delta_list({range(1,1,number_of_deltas)})'});
model.sol('sol3').feature('s1').set('stol', 1.0E-6);
model.sol('sol3').feature('s1').set('probesel', 'none');
model.sol('sol3').feature('s1').feature('aDef').set('cachepattern', true);
model.sol('sol3').feature('s1').feature('p1').set('control', 'user');
model.sol('sol3').feature('s1').feature('p1').set('pname', {'loc0'});
model.sol('sol3').feature('s1').feature('p1').set('plistarr', {'delta_list({range(1,1,number_of_deltas)})'});
model.sol('sol3').feature('s1').feature('p1').set('punit', {'um'});
model.sol('sol3').feature('s1').feature('p1').set('porder', 'constant');
model.sol('sol3').feature('s1').feature('p1').set('uselsqdata', false);
model.sol('sol3').feature('s1').feature('fc1').set('initstep', 0.1);
model.sol('sol3').feature('s1').feature('fc1').set('minsteprecovery', 0.001);
model.sol('sol3').feature('s1').feature('fc1').set('maxiter', 50);
model.sol('sol3').feature('s1').feature('d1').set('ooc', false);
model.sol('sol3').feature('s1').feature('d1').set('errorchk', false);
model.sol('sol3').runAll;