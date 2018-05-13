clear all

% Define parameters
petroModFolder = 'C:\Program Files\Schlumberger\PetroMod 2016.2\WIN64\bin';
projectFolder = 'C:\Users\malibrah\Desktop\TestPetromod2';

nDim = 2;
templateModel = 'LayerCake2';
newModel ='UpdatedModel';

% Open the project and create a new Model
PM = PetroMod(petroModFolder, projectFolder);

% Change some parameter
PM = PM.changeLithoValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)', '0.49');
PM.updateProject();

% Check if the parameter is updated
%PM.Lithology.getLithologyInfo('Sandstone (clay rich)')

% Create a new model and simulate
PM.copyModel(templateModel, newModel, nDim);
[output] = PM.simModel(newModel, nDim, true);

%% Test Binary Output

fileID = fopen('C:\Users\malibrah\Desktop\TestPetromod2\pm2d\LayerCake\out\xn29.pmb');
A = fread(fileID,[3 2],'double')
