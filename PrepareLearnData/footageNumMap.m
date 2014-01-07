hashKeyValue = csvimport('footageNumMap.csv');
key = hashKeyValue(:,1);
value = hashKeyValue(:,2);
numHash = containers.Map(key, value);

%useage example: numHash('footage_472_new') -> return 434
