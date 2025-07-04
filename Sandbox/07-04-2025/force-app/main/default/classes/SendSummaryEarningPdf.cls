public class SendSummaryEarningPdf {
    @InvocableMethod
    public static void sendSummaryEarningsPdf(List<FlowInput> inputs){
        FlowInput input = inputs[0];

        PageReference summaryPdf = Page.SummaryEarningPdf;
        summaryPdf.getParameters().put('accountName', input.accountName);
        summaryPdf.getParameters().put('summaryDetail', input.summaryDetail);
        summaryPdf.getParameters().put('earningsBreakdown', input.earningsBreakdown);
        summaryPdf.getParameters().put('summaryEarningsLast6Mos', input.summaryEarningsLast6Mos);
        Blob summaryPdfBody = summaryPdf.getContent();

        // 2. Create EmailFileAttachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Summary Earnings.pdf');
        attachment.setContentType('application/pdf');
        attachment.setBody(summaryPdfBody);

        // 3. Create and send the email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{input.emailAddRecipient});
        mail.setSubject('Summary Earnings PDF');
        mail.setPlainTextBody('Please find the Summary Earnings PDF attached.');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        // mail.setTargetObjectId(input.accountId); // Optional: Set target object id to relate email to account
        // mail.setSaveAsActivity(true); // Optional: Save email as activity on account

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public class FlowInput {
        @InvocableVariable
        public String accountName;
        @InvocableVariable
        public String summaryDetail;
        @InvocableVariable
        public String earningsBreakdown;
        @InvocableVariable
        public String summaryEarningsLast6Mos;
        @InvocableVariable
        public String emailAddRecipient;
    }
}