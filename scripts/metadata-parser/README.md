# Salesforce Metadata Parser

An ApexClass and ApexPage compatible parser to gather security information for classes and pages, respectively.

1. Run the ApexClass or ApexPage SOQL query listed at the bottom of the README
2. Download the plaintext CSV results from the query and paste it into 'queries/query_METADATA-TYPE.csv'
3. Run the SF Metadata Parser (either manually or with the provided button in the lower-left bar)
4. View the output in the 'results/output' directory (it will only run the most recently edited 'query_METADATA-TYPE.csv' file)

### ApexClass query

    SELECT Id, Name,
        (SELECT Parent.Id, Parent.Type, Parent.Label, Parent.PermissionSetGroupId, Parent.Profile.Id, Parent.Profile.Name
        FROM SetupEntityAccessItems
        ORDER BY Parent.Label ASC)
    FROM ApexClass
    WHERE NamespacePrefix = NULL
    ORDER BY Name ASC

### ApexPage query

    SELECT Id, Name,
        (SELECT Parent.Id, Parent.Type, Parent.Label, Parent.PermissionSetGroupId, Parent.Profile.Id, Parent.Profile.Name
        FROM SetupEntityAccessItems
        ORDER BY Parent.Label ASC)
    FROM ApexPage
    WHERE NamespacePrefix = NULL
    ORDER BY Name ASC
