model.component('comp1').geom('geom1').label('geometry1');
model.component('comp1').geom('geom1').lengthUnit([native2unicode(hex2dec({'00' 'b5'}), 'unicode') 'm']);
model.component('comp1').geom('geom1').create('i1', 'Interval');
model.component('comp1').geom('geom1').feature('i1').set('coord', {'0' 'L'});
model.component('comp1').geom('geom1').run;
model.component('comp1').geom('geom1').run('fin');
