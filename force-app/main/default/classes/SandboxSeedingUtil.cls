public with sharing class SandboxSeedingUtil {
  private static final List<String> EXCLUDED_FIELDS = new List<String>{
    'id',
    'isdeleted',
    'masterrecordid',
    'createddate',
    'createdById',
    'lastmodifieddate',
    'lastmodifiedbyid',
    'systemmodstamp'
  };
  private static final List<String> EXCLUDED_OBJECTS = new List<String>{
    'history',
    'tag',
    'group',
    'share',
    'feed',
    'public'
  };
  private static final List<String> FIRST_NAMES = new List<String>{
    'Oliver',
    'Rory',
    'Sam',
    'Daniel',
    'David',
    'Danielle',
    'Amy',
    'Heather',
    'Annie',
    'Josephine'
  };
  private static final List<String> LAST_NAMES = new List<String>{
    'Elsher',
    'Bardot',
    'West',
    'Hansley',
    'Marley',
    'Cassidy',
    'Langley',
    'Carter',
    'Lennon',
    'Adams'
  };
  private static final List<String> COMPANY_NAMES = new List<String>{
    'Conversify Tech',
    'Connective Solutions',
    'Communify',
    'Communex',
    'Buzzbox Media',
    'Dialogic Solutions',
    'Dialogix',
    'Speak Easy',
    'Interacto',
    'Chatterly'
  };

  @AuraEnabled(cacheable=true)
  public static List<String> getFields(String selectedObject) {
    if (String.isEmpty(selectedObject)) {
      return new List<String>();
    }
    List<String> reqFields = new List<String>();
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    Schema.SObjectType sobjType = gd.get(selectedObject);
    Schema.DescribeSObjectResult objectDescribe = sobjType.getDescribe();
    Map<String, Schema.SObjectField> mapOfFields = objectDescribe.fields.getMap();

    for (String fieldName : mapOfFields.keySet()) {
      System.debug(fieldName);
      System.debug(EXCLUDED_FIELDS.contains(fieldName));
      if (EXCLUDED_FIELDS.contains(fieldName)) {
        continue;
      }
      Schema.SObjectField field = mapOfFields.get(fieldName);
      Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
      System.debug('field-->' + field);
      System.debug('F-->' + fieldDescribe.getType()); //type of field
      reqFields.add(fieldDescribe.getName());
    }
    System.debug(reqFields);
    return reqFields;
  }
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getObjects() {
    Map<String, String> objectMap = new Map<String, String>();
    for (Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()) {
      String name = objTyp.getDescribe().getName();
      String label = objTyp.getDescribe().getLabel();
      if (
        !EXCLUDED_OBJECTS.contains(name) &&
        !objTyp.getDescribe().isCustomSetting() &&
        objTyp.getDescribe().isCreateable() &&
        objTyp.getDescribe().getRecordTypeInfos().size() > 0
      ) {
        objectMap.put(name, label);
      }
    }
    System.debug(objectMap);
    if (objectMap != null && objectMap.size() > 0) {
      return objectMap;
    } else {
      return null;
    }
  }

  @AuraEnabled
  public static void seedSandbox() {
    try {
      List<Seeding_Template__mdt> templates = [
        SELECT
          Id,
          Label,
          Object_Shape__c,
          Number_of_Records__c,
          Object_Api_Name__c
        FROM Seeding_Template__mdt
      ];
      if (templates.isEmpty()) {
        return;
      }
      List<SObject> objectsToCreate = new List<SObject>();
      for (Seeding_Template__mdt template : templates) {
        if (template.Object_Shape__c == null) {
          continue;
        }
        for (Integer i = 0; i < template.Number_of_Records__c; i++) {
          SObject objectToCreate = Schema.getGlobalDescribe()
            .get(template.Object_Api_Name__c)
            .newSObject();
          objectsToCreate.add(objectToCreate);
          List<SandboxSeedingUtil.SeedingTemplateField> fields = (List<SandboxSeedingUtil.SeedingTemplateField>) JSON.deserialize(
            template.Object_Shape__c,
            List<SandboxSeedingUtil.SeedingTemplateField>.class
          );
          if (fields.isEmpty()) {
            continue;
          }
          for (SandboxSeedingUtil.SeedingTemplateField field : fields) {
            switch on field.type {
              when 'CompanyName' {
                objectToCreate.put(
                  field.key,
                  COMPANY_NAMES[
                    Integer.valueOf(
                      Math.floor(Math.random() * ((FIRST_NAMES.size()) + 1))
                    )
                  ]
                );
              }
              when 'FirstName' {
                objectToCreate.put(
                  field.key,
                  FIRST_NAMES[
                    Integer.valueOf(
                      Math.floor(Math.random() * ((FIRST_NAMES.size()) + 1))
                    )
                  ]
                );
              }
              when 'LastName' {
                objectToCreate.put(
                  field.key,
                  FIRST_NAMES[
                    Integer.valueOf(
                      Math.floor(Math.random() * ((FIRST_NAMES.size()) + 1))
                    )
                  ]
                );
              }
              when 'Date' {
                objectToCreate.put(field.key, Date.today());
              }
              when 'Number' {
                objectToCreate.put(
                  field.key,
                  Math.floor(Math.random() * (10000) + 1)
                );
              }
              when 'SpecificValue' {
              }
              when else {
                //Assume text
                objectToCreate.put(field.key, 'Example Text');
              }
            }
          }
        }
      }
      insert objectsToCreate;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class SeedingTemplateField {
    public String type;
    public String key;

    SeedingTemplateField(String type, String key) {
      this.type = type;
      this.key = key;
    }
  }
}
