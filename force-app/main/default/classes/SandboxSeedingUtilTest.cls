@IsTest
public with sharing class SandboxSeedingUtilTest {
    @isTest
    private static void getObjectMapExcludesHistoryTagShareFeedGroupAndPublicObjects() {
        Map<String, String> objectMap = SandboxSeedingUtil.getObjects();

        System.assert(objectMap.size() > 0);
        System.assert(!objectMap.containsKey('history'), 'Expected \'history\' to be excluded');
        System.assert(!objectMap.containsKey('tag'), 'Expected \'tag\' to be excluded');
        System.assert(!objectMap.containsKey('share'), 'Expected \'share\' to be excluded');
        System.assert(!objectMap.containsKey('feed'), 'Expected \'feed\' to be excluded');
        System.assert(!objectMap.containsKey('group'), 'Expected \'group\' to be excluded');
        System.assert(!objectMap.containsKey('public'), 'Expected \'public\' to be excluded');
    }

    @isTest
    private static void testGetFieldsForAccount() {
        List<String> fields = SandboxSeedingUtil.getFields('Account');
        System.assert(fields.size() > 0, 'No fields found for Account');
    }   
            
}