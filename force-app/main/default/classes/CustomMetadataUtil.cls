public with sharing class CustomMetadataUtil implements Metadata.DeployCallback {
  @AuraEnabled
  public static void insertSeedingTemplate(
    Seeding_Template__mdt seedingTemplate
  ) {
    // Seeding_Template__mdt result = new Seeding_Template__mdt();
    // result.Label = seedingTemplate.Label;
    // result.Object_Shape__c = seedingTemplate.Object_Shape__c;

    // try {
    //     insert result;
    //     return result;
    // } catch (Exception e) {
    //      throw new AuraHandledException('Unable to create new seeding template');
    // }
    System.debug(seedingTemplate);

    // Setup custom metadata to be created in the subscriber org.
    Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
    customMetadata.fullName = 'Seeding_Template__mdt.' + seedingTemplate.Label;
    customMetadata.label = seedingTemplate.Label;
    Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
    customField.field = 'Object_Shape__c';
    customField.value = seedingTemplate.Object_Shape__c;

    customMetadata.values.add(customField);

    //    Metadata.CustomMetadataValue labelField = new Metadata.CustomMetadataValue();
    //    labelField.field = 'MasterLabel';
    //    labelField.value = seedingTemplate.MasterLabel;

    //    customMetadata.values.add(labelField);

    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    mdContainer.addMetadata(customMetadata);

    // Setup deploy callback, MyDeployCallback implements
    // the Metadata.DeployCallback interface (code for
    // this class not shown in this example)
    CustomMetadataUtil callback = new CustomMetadataUtil();

    // Enqueue custom metadata deployment
    Id deployRequestId = Metadata.Operations.enqueueDeployment(
      mdContainer,
      callback
    );
  }

  public void handleResult(
    Metadata.DeployResult result,
    Metadata.DeployCallbackContext context
  ) {
    if (result.status == Metadata.DeployStatus.Succeeded) {
      System.debug('success: ' + result);
    } else {
      // Deployment was not successful
      System.debug('fail: ' + result.errorMessage);
    }
  }
}
