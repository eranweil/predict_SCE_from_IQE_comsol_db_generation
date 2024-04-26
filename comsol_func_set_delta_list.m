model.func.create('int14', 'Interpolation');
model.func('int14').label('delta_list');
model.func('int14').set('funcname', 'delta_list');
b=table2cell(delta_list,ones(size(delta_list,1),1),ones(size(delta_list,2),1));
c=cellfun(@num2str,b,'uni',false);
model.func('int14').set('table', c);
model.func('int14').set('extrap', 'linear');
model.func('int14').set('fununit', 'um');