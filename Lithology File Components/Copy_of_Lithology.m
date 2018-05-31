classdef Lithology < handle
   properties
       lithology
       lithologyGroupTitles = {'Id', 'Name', 'ReadOnly', 'PetroModId'}
       lithologyTitles = {'Id', 'Name', 'ReadOnly', 'PetroModId', 'Pattern' , 'Color'};
       parameterGroupTitles = {'MetaParameterGroupId'};
       parameterTitles = {'MetaParameterId', 'Value'};
   end
   
   methods
       % =========================================================
       function obj = Lithology(lithologyGroupNodes)
            if exist('lithologyGroupNodes','var') == true
                obj.lithology = obj.analyzeLithologyGroupNodes(lithologyGroupNodes);  
            end 
       end
       
       % =========================================================
       function lithologyAll = analyzeLithologyGroupNodes(obj, lithologyGroupMainNodes)
           nLithologyGroupMainNodes = lithologyGroupMainNodes.getLength;
           lithologyAll = {};
           for i=0:nLithologyGroupMainNodes-1
               lithologyGroupNodeMain = lithologyGroupMainNodes.item(i);
               lithologyGroupMain = obj.analyzeLithologyGroupNodeMain(lithologyGroupNodeMain);
               lithologyAll = [lithologyAll; lithologyGroupMain];
           end
       end
       
       % =========================================================
       function lithologyGroupMain = analyzeLithologyGroupNodeMain(obj, lithologyGroupNodeMain)
          id   = char(lithologyGroupNodeMain.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name   = char(lithologyGroupNodeMain.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(lithologyGroupNodeMain.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petroModId   = char(lithologyGroupNodeMain.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);

          lithologyGroupSubNodes = lithologyGroupNodeMain.getElementsByTagName('LithologyGroup');
          nLithologyGroupSubNodes = lithologyGroupSubNodes.getLength;
          
          lithologyGroupMain = {};
          lithologyGroupSubRows = {};
          for i=0:nLithologyGroupSubNodes-1               
               lithologyGroupNodeSub = lithologyGroupSubNodes.item(i);
               lithologyGroupSub = obj.analyzeLithologyGroupNodeSub(lithologyGroupNodeSub);
               
               nRows = size(lithologyGroupSub,1);
               ids   = repmat({id},nRows,1);
               names = repmat({name}, nRows,1);
               readOnlys = repmat({readOnly}, nRows,1);
               petroModIds = repmat({petroModId}, nRows, 1);
               lithologyGroupSubMatrix = [ids, names, readOnlys, petroModIds, lithologyGroupSub];
               lithologyGroupSubRows = [lithologyGroupSubRows; lithologyGroupSubMatrix];
          end
               lithologyGroupMain = [lithologyGroupMain; lithologyGroupSubRows];

       end
       
       % =========================================================
       function lithologyGroupSub = analyzeLithologyGroupNodeSub(obj, lithologyGroupNodeSub)
          id   = char(lithologyGroupNodeSub.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name   = char(lithologyGroupNodeSub.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(lithologyGroupNodeSub.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petroModId   = char(lithologyGroupNodeSub.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);

          lithologyNodes = lithologyGroupNodeSub.getElementsByTagName('Lithology');
          nLithologyGroupSubNodes = lithologyNodes.getLength;
          
          lithologyRow = {};
          lithologyGroupSub = {};
          for i=0:nLithologyGroupSubNodes-1
               lithologyNode = lithologyNodes.item(i);
               lithology = obj.analyzeLithologyNode(lithologyNode);
               lithologyRows(i+1,:) = [id, name, readOnly, petroModId, lithology];
          end
          lithologyGroupSub = [lithologyGroupSub; lithologyRows];
       end
       
       
       % =========================================================
      function lithology = analyzeLithologyNode(obj, lithologyNode)

          id         = char(lithologyNode.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name       = char(lithologyNode.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(lithologyNode.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petroModId = char(lithologyNode.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);
          pattern = char(lithologyNode.getElementsByTagName('Pattern').item(0).getFirstChild.getData);
          color      = char(lithologyNode.getElementsByTagName('Color').item(0).getFirstChild.getData);

          parameterGroupNodes = lithologyNode.getElementsByTagName('ParameterGroup');
          nPrameterGroups = parameterGroupNodes.getLength;
          parameterGroup = {};
          
          for i = 0:nPrameterGroups-1
             parameterGroupNode = parameterGroupNodes.item(i);
             parameterGroupRow  = obj.analyzeParameterGroup(parameterGroupNode);
             parameterGroup     = [parameterGroup; parameterGroupRow];
          end
          lithology = {id, name, readOnly, petroModId, pattern, color, parameterGroup};
      end 
      
       % =========================================================
       function [parameterGroup] = analyzeParameterGroup(obj, parameterGroupNode)
          id = char(parameterGroupNode.getElementsByTagName('MetaParameterGroupId').item(0).getFirstChild.getData);

          parameterNodes = parameterGroupNode.getElementsByTagName('Parameter');
          nPrameters = parameterNodes.getLength;
         
          parameterGroup = {};   
          for i = 0:nPrameters-1
              parameterNode =  parameterNodes.item(i);
              parameter = obj.analyzeParameter(parameterNode);
              parameterGroupRow = {id, parameter{1}, parameter{2}};
              parameterGroup = [parameterGroup; parameterGroupRow];
          end
       end
       
       % =========================================================
       function [parameter] = analyzeParameter(obj, parameterNode)
           id = char(parameterNode.getElementsByTagName('MetaParameterId').item(0).getFirstChild.getData); 
           value = char(parameterNode.getElementsByTagName('Value').item(0).getFirstChild.getData);
           parameter = {id, value};
       end
       
   end

   methods
       
      % =========================================================

       function lithologyParameters =  getLithologyParameters(obj, lithologyName)
            lithologyIndex = obj.getLithologyIndex(lithologyName);
            if any(lithologyIndex) == false 
                disp('Could not find lithology!'); 
                lithologyParameters = '';
                return; 
            end
            lithologyParameters = obj.lithology{lithologyIndex, end};
       end
       
      % =========================================================   
       function obj = updateLithologyParametersValue(obj, lithologyName, id, value)
           
           if isa(value, 'double') == true; value = num2str(value); end 
           if iscell(value) == false; value = cellstr(value); end
           
            idIndex    =   numel(obj.parameterGroupTitles)+find(ismember(obj.parameterTitles, 'MetaParameterId'));
            valueIndex =   numel(obj.parameterGroupTitles)+find(ismember(obj.parameterTitles, 'Value'));
                   
            lithologyIndex = obj.getLithologyIndex(lithologyName);
            lithologyParameters = obj.lithology{lithologyIndex, end};
            parameterIndex = ismember(lithologyParameters(:,idIndex),id);
            
            lithologyParameters(parameterIndex,valueIndex) =  value;

            obj.lithology{lithologyIndex, end} = lithologyParameters;
       end
       
       
       % =========================================================   
       function curveId = getCurveId(obj, lithologyName, id)
           
            idIndex    =   numel(obj.parameterGroupTitles)+find(ismember(obj.parameterTitles, 'MetaParameterId'));
            valueIndex =   numel(obj.parameterGroupTitles)+find(ismember(obj.parameterTitles, 'Value'));
                   
            lithologyIndex = obj.getLithologyIndex(lithologyName);
            lithologyParameters = obj.lithology{lithologyIndex, end};
            parameterIndex = ismember(lithologyParameters(:,idIndex),id);
            
            curveId = lithologyParameters(parameterIndex,valueIndex);
       end
       
       % =========================================================   
       function lithologyIndex = getLithologyIndex(obj, lithologyName)
          nameIndex  = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Name'));
          lithologyIndex = ismember(obj.lithology(:,nameIndex), lithologyName);
       end
       % =========================================================   
       function ids = getIds(obj)
           idIndex1  = find(ismember(obj.lithologyGroupTitles, 'Id'));
           idIndex2  = numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyGroupTitles, 'Id'));
           idIndex3  = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Id'));         
           ids = [obj.lithology(:,idIndex1); obj.lithology(:,idIndex2); obj.lithology(:,idIndex3)];
           keepInd = cellfun(@(x) ~isempty(x), ids);
           ids = ids(keepInd);
           ids = unique(cell2mat(ids),'rows');
           ids = cellstr(ids);
       end
       
       function [] = dublicateLithology(obj, sourceLithoName, distLithoName, hash)
           lithologyIndex = obj.getLithologyIndex(sourceLithoName);
           newLithology = obj.lithology(lithologyIndex,:);
           idIndex  = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Id'));         
           nameIndex  = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Name'));         
           newLithology{:,idIndex} = hash;
           newLithology{:,nameIndex} = distLithoName;
           obj.lithology(end+1,:)= newLithology;
       end
       
   end
    
 % Get methods
 methods
     
     function [docNode] = writeLithologyNode(obj, docNode)
        
        [infoLithologyGroup, nRecordsLithologyGroup] = getLithologyGroup(obj);
        for i=1:nRecordsLithologyGroup
            lithologyGroupElement = XMLTools.addElement(docNode, 'LithologyGroup');    
            for j=1:numel(obj.lithologyGroupTitles)
                    XMLTools.addElement(lithologyGroupElement, obj.lithologyGroupTitles{j}, infoLithologyGroup{i,j});
            end
            
               [infoLithologyGroup2, nRecordsLithologyGroup2] = getLithologyGroup2(obj, infoLithologyGroup{i,1});
               if nRecordsLithologyGroup2> 0
               for k=1:nRecordsLithologyGroup2
                   lithologyGroupElement2 = XMLTools.addElement(lithologyGroupElement, 'LithologyGroup');
                   for l=1:numel(obj.lithologyGroupTitles)
                    XMLTools.addElement(lithologyGroupElement2, obj.lithologyGroupTitles{l}, infoLithologyGroup2{k,l});
                   end
                   
                  
                   [infoLithology, nRecordsLithology] = getLithology(obj, infoLithologyGroup{i,1}, infoLithologyGroup2{k,1});
                   if nRecordsLithology> 0
                   for o=1:nRecordsLithology
                   lithologyElement = XMLTools.addElement(lithologyGroupElement2, 'Lithology');
                       for p=1:numel(obj.lithologyTitles)
                            XMLTools.addElement(lithologyElement, obj.lithologyTitles{p}, infoLithology{o,p});
                       end
                   
                   parametersTable = infoLithology{o,end};
                   [~,ia,~] = unique(parametersTable(:,1));
                   metaParameterId = parametersTable(ia,1);
                   for q = 1:numel(ia)
                       parameterGroupElement = XMLTools.addElement(lithologyElement, 'ParameterGroup');
                       XMLTools.addElement(parameterGroupElement, 'MetaParameterGroupId', metaParameterId{q});

                       indToInclude = ismember(parametersTable(:,1), metaParameterId{q});
                       parameters = parametersTable(indToInclude, 2:3);
                       for r = 1:sum(indToInclude)
                            parameterElement = XMLTools.addElement(parameterGroupElement, 'Parameter');
                            XMLTools.addElement(parameterElement, 'MetaParameterId', parameters{r,1});
                            XMLTools.addElement(parameterElement, 'Value', parameters{r,2});
                       end
                   end
                   
                       
                   end
                   end
                   
                   
                   
                   
               end
               end
            
        end
         
         
     end
     
     
      function [info, nRecords] = getLithologyGroup(obj)
           startIndex = 1;
           endIndex   = numel(obj.lithologyGroupTitles);
           id = obj.lithology(:,startIndex);           
           [~,ia,~] = unique(id);
           nRecords = numel(ia);
           info =  obj.lithology(ia,startIndex:endIndex);
      end
       
      
       function [info, nRecords] = getLithologyGroup2(obj, lithologyGroupId)
           startIndex = numel(obj.lithologyGroupTitles)+1;
           endIndex   = startIndex+numel(obj.lithologyGroupTitles)-1;  
           indMember = ismember(obj.lithology(:,1), lithologyGroupId);
           lithology = obj.lithology(indMember,:);
           [~, ia,~] = unique(lithology(:,startIndex));
           nRecords = numel(ia);
           info =  lithology(ia,startIndex:endIndex);
       end
       
       
       
       function [info, nRecords] = getLithology(obj, lithologyGroupId, lithologyGroupId2)
           % Index Meta Parameter Group
           indMember = ismember(obj.lithology(:,1), lithologyGroupId);
           lithology = obj.lithology(indMember,:);
           
           %Only Take Meta Parameter Group without SubGroup
           idLith2 = lithology(:,numel(obj.lithologyGroupTitles)+1);           
           indMember = ismember(idLith2, lithologyGroupId2);
           lithology =  lithology(indMember,:);
           
           % Get info
           nRecords = size(lithology,1);
           startIndex = 2*numel(obj.lithologyGroupTitles)+1;
           info =  lithology(:,startIndex:end);
           
       end
      

 end
    
end