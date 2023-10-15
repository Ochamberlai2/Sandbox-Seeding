public with sharing class SandboxSeedingUtil {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getFields(String selectedObject){
        List<String> reqFields = new List<String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult objectDescribe = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = objectDescribe.fields.getMap();
        
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            System.debug('field-->'+field);
            System.debug('F-->'+fieldDescribe.getType()); //type of field
	        reqFields.add(fieldDescribe.getName());
        }
        System.debug(reqFields);
        return reqFields;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getObjects(){
        Map<String,String> objectMap = new Map<String,String>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
           String name = objTyp.getDescribe().getName();
           String label = objTyp.getDescribe().getLabel();
           if(!name.containsignorecase('history') && !name.containsignorecase('tag') &&
                !name.containsignorecase('share') && !name.containsignorecase('feed') && 
               	!name.containsignorecase('group') && !name.containsignorecase('public') &&
                !objTyp.getDescribe().isCustomSetting() && objTyp.getDescribe().isCreateable() &&
                objTyp.getDescribe().getRecordTypeInfos().size() > 0){      
                objectMap.put(name,label);
           }
        }
		System.debug(objectMap);
        if(objectMap != null && objectMap.size() > 0){
        	return objectMap;   
        }else{
            return null;
        }
    }
}