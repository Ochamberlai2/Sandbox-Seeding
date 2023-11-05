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
  public static string getObjectNameFromLookup(
    String objectName,
    String fieldName
  ) {
    try {
      Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe()
        .get(objectName)
        .getDescribe()
        .fields
        .getMap()
        .get(fieldName)
        .getDescribe();

      return fieldDescribe.getReferenceTo()[0].getDescribe().getName();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
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
      Map<SObject, Map<String, SObject>> objectsToCreate = new Map<SObject, Map<String, SObject>>();
      for (Seeding_Template__mdt template : templates) {
        if (template.Object_Shape__c == null) {
          continue;
        }
        for (Integer i = 0; i < template.Number_of_Records__c; i++) {
          List<SandboxSeedingUtil.SeedingTemplateField> fields = (List<SandboxSeedingUtil.SeedingTemplateField>) JSON.deserialize(
            template.Object_Shape__c,
            List<SandboxSeedingUtil.SeedingTemplateField>.class
          );
          List<SandboxSeedingUtil.SeedingTemplateField> lookupFields = new List<SandboxSeedingUtil.SeedingTemplateField>();
          Map<String, SObject> lookupFieldObjects = new Map<String, SObject>();
          //Find out if one of the fields is a lookup
          for (SandboxSeedingUtil.SeedingTemplateField field : fields) {
            if (field.type == 'Lookup') {
              lookupFields.add(field);
            }
          }
          //build a list of these to create
          for (SandboxSeedingUtil.SeedingTemplateField field : lookupFields) {
            lookupFieldObjects.put(
              field.key,
              createObject(
                field.lookupObjectName,
                JSON.serialize(field.lookupValue)
              )
            );
          }
          objectsToCreate.put(
            createObject(template.Object_Api_Name__c, template.Object_Shape__c),
            lookupFieldObjects
          );
        }
      }

      List<SObject> lookupObjects = new List<SObject>();
      //now we should have the map of objects to lookups. So we need to insert the lookups
      //find the list of lookup records to create
      for (Map<String, SObject> lookupMap : objectsToCreate.values()) {
        lookupObjects.addAll(lookupMap.values());
      }
      insert lookupObjects;

      //now we need to find the objects to update the lookup Ids of
      for (SObject objectKey : objectsToCreate.keySet()) {
        Map<String, SObject> insertedValues = objectsToCreate.get(objectKey);
        for (String key : insertedValues.keySet()) {
          objectKey.put(key, insertedValues.get(key).Id);
        }
      }
      insert new List<SObject>(objectsToCreate.keySet());
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @TestVisible
  private static SObject createObject(
    String objectApiName,
    String objectShape
  ) {
    SObject objectToCreate = Schema.getGlobalDescribe()
      .get(objectApiName)
      .newSObject();

    System.debug(objectShape);
    List<SandboxSeedingUtil.SeedingTemplateField> fields = (List<SandboxSeedingUtil.SeedingTemplateField>) JSON.deserialize(
      objectShape,
      List<SandboxSeedingUtil.SeedingTemplateField>.class
    );
    if (fields.isEmpty()) {
      return null;
    }

    for (SandboxSeedingUtil.SeedingTemplateField field : fields) {
      switch on field.type {
        when 'CompanyName' {
          objectToCreate.put(
            field.key,
            COMPANY_NAMES[
              Integer.valueOf(
                Math.floor(Math.random() * ((FIRST_NAMES.size())))
              )
            ]
          );
        }
        when 'FirstName' {
          objectToCreate.put(
            field.key,
            FIRST_NAMES[
              Integer.valueOf(
                Math.floor(Math.random() * ((FIRST_NAMES.size())))
              )
            ]
          );
        }
        when 'LastName' {
          objectToCreate.put(
            field.key,
            FIRST_NAMES[
              Integer.valueOf(Math.floor(Math.random() * ((LAST_NAMES.size()))))
            ]
          );
        }
        when 'Date' {
          objectToCreate.put(field.key, Date.today());
        }
        when 'Number' {
          objectToCreate.put(field.key, Crypto.getRandomInteger());
        }
        when 'SpecificValue' {
          objectToCreate.put(field.key, field.specificValue);
        }
        // when 'Lookup' {
        //   output.addAll(
        //     createObject(
        //       field.lookupObjectName,
        //       JSON.serialize(field.lookupValue)
        //     )
        //   );
        // }
        when else {
          //Assume text
          objectToCreate.put(field.key, 'Example Text');
        }
      }
    }
    return objectToCreate;
  }

  public class SeedingTemplateField {
    public String type;
    public String key;
    public String specificValue;
    public String lookupObjectName;
    public List<SeedingTemplateField> lookupValue;

    SeedingTemplateField(
      String type,
      String key,
      String specificValue,
      String lookupObjectName,
      List<SeedingTemplateField> lookupValue
    ) {
      this.type = type;
      this.key = key;
      this.specificValue = specificValue;
      this.lookupObjectName = lookupObjectName;
      this.lookupValue = lookupValue;
    }
  }
}
