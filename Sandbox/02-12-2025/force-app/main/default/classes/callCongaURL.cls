public class callCongaURL {
    
    public static void generateDocs(String recordId) {
        // Base Conga Composer URL (ensure you have Conga installed and configured)
        String baseUrl = 'https://composer.congamerge.com/composer8/';
        
        // Template ID for Conga Composer (replace with your actual template ID)
        String templateId = '0T_008EAI305494'; 
        //List<Id> recordIds = new List<Id>{'0019000001LZ9HWAA1'};
        
        String orgBaseUrl = System.URL.getOrgDomainUrl().toExternalForm();
        String congaUrl;
        
        
        // Loop through the record IDs to generate a document for each
        //for (Id recordId : recordIds) {
            // Build the Conga Composer URL dynamically
            congaUrl = baseUrl + '?sessionId=' + UserInfo.getSessionId()
                + '&serverUrl=' + orgBaseUrl
                + '&Id=' + recordId
                + '&TemplateId=' + templateId
                + '&DS7=1' // Optional: Delivery method (e.g., save in Salesforce Files)
                + '&QueryId=[SDBBrandedUS2]0Q_291EAI845670,[SDBEyeotaOthers3]0Q_314EAI906278,[SDBBrandedOthers3]0Q_315EAI527562,[SDBLast6Mos]0Q_184EAI862019,[SDBBreakdown]0Q_189EAI886363,[SDBCustom]0Q_188EAI498046,[SDBEyeotaES]0Q_209EAI939755,[SDBEyeotaAU]0Q_190EAI536087,[SDBEyeotaDE]0Q_191EAI459357,[SDBEyeotaUK]0Q_193EAI059790,[SDBEyeotaIN]0Q_216EAI210919,[SDBEyeotaCA]0Q_201EAI592709,[SDBEyeotaJP]0Q_217EAI194797,[SDBEyeotaMX]0Q_220EAI085889,[SDBEyeotaNZ]0Q_224EAI844272,[SDBEyeotaRU]0Q_228EAI935536,[SDBEyeotaTR]0Q_232EAI929439,[SDBEyeotaTW]0Q_233EAI817406,[SDBMonth]0Q_237EAI934324,[SDBEyeotaFR]0Q_211EAI184463,[SDBEyeotaHK]0Q_212EAI422941,[SDBEyeotaIT]0Q_215EAI924778,[SDBEyeotaNL]0Q_222EAI950758,[SDBEyeotaPL]0Q_226EAI082782,[SDBBrandedAU]0Q_238EAI482915,[SDBBrandedUK]0Q_241EAI233923,[SDBBrandedFR]0Q_259EAI181792,[SDBBrandedHK]0Q_262EAI602874,[SDBBrandedIT]0Q_264EAI194006,[SDBBrandedDE]0Q_239EAI342117,[SDBBrandedBR]0Q_248EAI216187,[SDBBrandedES]0Q_257EAI813544,[SDBBrandedCA]0Q_249EAI602006,[SDBBrandedMX]0Q_268EAI810404,[SDBBrandedPL]0Q_274EAI586099,[SDBBrandedIN]0Q_286EAI631167,[SDBBrandedJP]0Q_265EAI003941,[SDBBrandedNL]0Q_270EAI015003,[SDBBrandedNZ]0Q_272EAI879009,[SDBBrandedRU]0Q_276EAI495759,[SDBBrandedTR]0Q_280EAI901557,[SDBBrandedTW]0Q_281EAI769271,[SalesDBUSUS3]a7Y0o0000008Rao,[SalesDBUSOthers2]a7Y0o0000008RaU,[SalesDBOthers1]a7Y0o0000008RaZ,[SalesDBOthers2]a7Y0o0000008RaP,[SalesDBUSUS1]a7Y0o0000008RZ7,[SalesDBUSUS2]a7Y0o0000008Raj,[SalesDBUSOthers1]a7Y0o0000008RaK,[SDBBrandedUS3]0Q_316EAI911399,[SDBEyeotaUS3]0Q_317EAI799229,[SalesDBOthers3]0Q_318EAI961734,[SDBEyeotaNORDICS]0Q_295EAI381534,[SDBEyeotaOthers1]0Q_300EAI452092,[SDBBrandedOthers1]0Q_293EAI068587,[SDBBrandedOthers2]0Q_294EAI277183,[SDBEyeotaSEA1]0Q_296EAI543156,[SDBEyeotaSEA2]0Q_297EAI407197,[SDBBrandedNORDICS]0Q_288EAI216706,[SDBEyeotaOthers2]0Q_301EAI257594,[SDBBrandedSEA1]0Q_289EAI925122,[SDBBrandedSEA2]0Q_290EAI163518,[SDBEyeotaUS1]0Q_299EAI995705,[SDBEyeotaBR]0Q_200EAI674083,[SDBEyeotaUS2]0Q_298EAI403193,[SDBBrandedUS1]0Q_292EAI660290,[SDBBreakdown1]0Q_346MAI488904' // Optional: Conga Query ID if needed
                + '&OutputFormat=XLSX'; // Change to your desired output format (PDF, Word, etc.)
        
            // Debug or log the URL for testing purposes
            System.debug('Generated Conga URL: ' + congaUrl);
            execCongaURL(congaUrl);
        //e}
        
    }
    
    @future(callout=true)
    public static void execCongaURL(String url) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
    
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
             
                Blob fileContent = res.getBodyAsBlob();
                
                // Create a Salesforce File (ContentVersion)
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Generated Conga Document'; // Replace with your desired file name
                cv.PathOnClient = 'GeneratedDocument.xlsx'; // Replace with desired file extension
                cv.VersionData = fileContent; // Add the file content here
                insert cv;
                
                String contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
    
                // Step 3: Create a ContentDocumentLink to associate the file with the Account
                ContentDocumentLink link = new ContentDocumentLink();
                link.ContentDocumentId = contentDocId;
                link.LinkedEntityId = '0019000001LZ9HWAA1'; // Link to the Account
                link.ShareType = 'V'; // View-only access
                link.Visibility = 'AllUsers'; // Optional: Set visibility
                insert link;
                
                System.debug('Conga document generated successfully.');	
            } else {
                System.debug('Error in Conga callout: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception in Conga callout: ' + e.getMessage());
        }
    }
}