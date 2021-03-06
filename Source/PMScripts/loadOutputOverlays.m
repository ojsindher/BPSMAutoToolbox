function [data, layerNames, units, status] = loadOutputOverlays(modelName, nDim, PM, overlayNumbers)
% Mustafa Al Ibrahim @ 2018, Stanford BPSM
% Email:    Mustafa.Geoscientist@outlook.com
% Linkedin: https://www.linkedin.com/in/mosgeo/ 

scriptFolder = fullfile(fileparts(fileparts(PM.PMDirectory)), 'scripts');
scriptName  = 'demo_opensim_output_3rd_party_format';

data = []; 
layerNames=[];
for iLayer = 1:numel(overlayNumbers)
    [cmdout, status] = PM.runScript(modelName, nDim, scriptName, num2str(overlayNumbers(iLayer)), false, false, scriptFolder);
    if PM.version >= 2018
        outputFileName =  fullfile(PM.getModelFolder(modelName, nDim),'out','demo_1.txt') ;
    else
        outputFileName = 'demo_1.txt';
    end
    [id, value, layer, unit, status] = readDemoScriptOutput(outputFileName, true, true);  
    data = [data, value];
    layerNames{iLayer} = layer;
    units{iLayer} = unit;
end

end