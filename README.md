# [PCRE-testcases](https://github.com/OWASP/SEDATED/blob/master/testing/regex_testing/test_cases.txt)

## Initial Scan Results

| Change Description | Default | Generic |
|---------------------|---------|---------|
| Add test_cases.txt | 2  | 4  |
| change to java file | | adds 9 Passwords |

----

## GitHub Secret Scanning - One File Test Case
- Once a secret is detected in a file, that same secret will not be shown as an additional alert and will not be blocked by push protection as it should be revoked - unless its in a different repo
  - The same secret in different files is shown in the same alert
- The same secret shown will not be shown in multiple locations in a file
  

## PCRE Test Cases w/ GHSP
Their is a fundamental difference in detection methodologies with GitHub vs PCRE regex.
- [Provider Patterns](https://docs.github.com/en/code-security/secret-scanning/introduction/supported-secret-scanning-patterns#default-patterns) (Tokens) - GitHub uses regex & checksums directly from the [partners](https://docs.github.com/en/code-security/secret-scanning/secret-scanning-partnership-program/secret-scanning-partner-program#identify-your-secrets-and-create-regular-expressions) with uniquely defined prefixes and high entropy random strings
- [Non-Provider Patterns](https://docs.github.com/en/code-security/secret-scanning/introduction/supported-secret-scanning-patterns#non-provider-patterns) - Everything Else (Passwords, private keys, connection strings)
  - [Custom Patterns](https://docs.github.com/en/enterprise-cloud@latest/code-security/secret-scanning/using-advanced-secret-scanning-and-push-protection-features/custom-patterns) are how GitHub augments Non-Providers with user provided regex that allows for push protection

In general the majority of the test cases do not contain valid tokens or "real" passwords.  In order to properly test, each example should be added to an individual file with a real token if counting raw alert numbers.  For [Copilot Generic Secret Detection](https://docs.github.com/en/code-security/secret-scanning/copilot-secret-scanning/responsible-ai-generic-secrets), the filename should not contain test and should not be a txt file.  See [generic password limitations by design](https://docs.github.com/en/enterprise-cloud@latest/code-security/secret-scanning/copilot-secret-scanning/responsible-ai-generic-secrets#limitations-by-design) for all criteria.

### [Provider Patterns](./testbed/provider_patterns/)
Requires a valid token, not something with EXAMPLE or 123456 in the string.  
AWS Keys require both secret + key to be validity checked
GitHub uses regex & checksums directly from the [partners](https://docs.github.com/en/code-security/secret-scanning/secret-scanning-partnership-program/secret-scanning-partner-program#identify-your-secrets-and-create-regular-expressions) with uniquely defined prefixes and high entropy random strings

- AWS_Keys - majority are not valid and don't contain key + secret pair
- Slack_Token - 100% accuracy as the token provided is real
- Facebook_Token - not a real key 
- GitHub_Token - does not look for correct pattern - uses github looking in enclosed quotes
- Twitter_Token - not supported requires custom pattern or feature request
- Heroku_Token - not supported requires custom pattern or feature request

### [Non-Provider Patterns](./testbed/non_provider_patterns/)

- Private_Keys - do not contain keys just headers
  - DSA & EC - not supported requires custom pattern or feature request
- Basic_Auth - 2/4 have valid tokens
- .npmrc_auth - not supported requires custom pattern or feature request
- Connection_String & JDBC_Connection_String - not supported requires custom pattern or feature request
  - MongoDB, mysql support, postgres

### Custom Patterns
#### Keys
Looking for `aws`, `access`, `api`, `app`, `application`, `private`, `sensitive`, `secret`
- Keys - aws is supported through provider patterns the remaining are not supported and require custom pattern or feature request

#### Passwords
Test cases do not contain "real" passwords for AI to detect.  
Looking for `password`, `passwd`, `pswd`, `secret` in different permutations
- Password_Generic_with_quotes
- Password_equal_no_quotes
- Password_value
- Password_primary
- Password_XML
- Password_colon_no_quotes 
- Password_Generic_with_quotes
- Password_equal_no_quotes

#### Required Patterns for PCRE Parity
- DSA & EC Private Keys - `DSA|EC`
- .npmrc_auth - `_auth`
- Connection_String - `username:password@host`
- JDBC_Connection_String - `jdbc:oracle:thin`
- Keys - `access`, `api`, `app`, `application`, `private`, `sensitive`, `secret`
- Passwords - `password`, `passwd`, `pswd`, `secret`

## [PCRE Regex](https://github.com/OWASP/SEDATED/blob/master/config/regexes.json) 

### Manual Testing with [regex101.com](https://regex101.com/)

| Pattern Name | True Positives | False Positives | Total Fail Cases | % Accuracy |
| --- | ---- | --- | --- | --- |
| Slack_Token | 1 | 0 | 1 | 100% |
| Connection_String | 2 | 0 | 2 | 100% |
| Private_Key | 12 | 0 | 15 | 80% |
| AWS_Key | 13 | 0 | 17 | 76% |
| Basic_Auth | 3 | 0 | 4 | 75% |
| JDBC_Connection_String | 3 | 0 | 4 | 75% |
| Heroku_Key | 2 | 0 | 3 | 66% |
| Twitter_Token | 1 | 0 | 3 | 25% |
| Passwords | 92 | 33 | 446 | 13% |
| Keys | 5 | 0 | 73 | 7% |
| Filename |0|0|0|0%|
| AWS_Key_line_end |0|0|0|0%|
| .npmrc_auth |0|0|0|0%|
| GitHub_Token |0|0|0|0%|


### Local PCRE Regex Testing
```shell
docker run --name PCRE-test -i -d ubuntu:latest
docker exec -it PCRE-test bash

apt update && export DEBIAN_FRONTEND=noninteractive && apt install -y git curl nano vim unzip zip jq

git clone https://github.com/OWASP/SEDATED.git && cd SEDATED/testing/regex_testing
chmod +x regex_test_script.sh && ./regex_test_script.sh
```

#### Seperating Pass/Fail & Regex Concatentation 
583 fail cases 
549 pass cases
```shell
grep '>>fail$' "local-tests/test_cases.txt" > "local-tests/fail.txt"
grep '>>pass$' "local-tests/test_cases.txt" > "local-tests/pass.txt"

wc -l local-tests/fail.txt && wc -l local-tests/pass.txt
```
440 missed test cases when running each regex seperate instead of concatenating with new [test script](./local-tests/regex_test_individual.sh) 


| SUMMARY: | 25% ACCURACY |
|---|---|
|MISSED BY REGEX: | 440 |
|MATCHED BY REGEX: | 143 |
----
| Regex | Matches |
| --- | --- |
|Slack_token: | 1 |
|Connection_String: | 2 |
|Private_Key: |12|
|AWS_Key: | 11 |
|Basic_Auth: | 3 |
|JDBC_Connection_Creds: | 3 |
|.npmrc_auth: | 9 |
|Heroku_Key: |2|
|Twitter_Token: |1|
|Keys: | 5 |
|Keys_no_space: | 1 |
|Facebook_Token: | 1 |
|Password_equal_no_quotes: |32|
|Password_Generic_with_quotes: | 24 |
|Password_colon_no_quotes: |21|
|Password_XML: |11|
|Password_value: | 3 |
|Password_primary: | 1 |


## GitHub Custom Patterns
### Results
[Regex patterns and research](./regex.md)
| Pattern Name | True Positives | False Positives |
| --- | ---- | --- |
| EC & DSA Private Keys | 6 | 0 |
| jdbc_connection_string | 5 | 1 |
| connection_string | 13 | 0 |
| _auth | 5 | 0 |
| Keys | 73 | 7 |
| Passwords | 167 | 51 |



## Additional Research
### Creating High Entropy Single File Key Password Tests for [Copilot Generic Secret Detection](https://docs.github.com/en/code-security/secret-scanning/copilot-secret-scanning/responsible-ai-generic-secrets)

```shell
grep -iE 'access|api|app|application|private|sensitive|secret' "test_cases.txt" > "keys.txt"
grep -iE 'password|passwd|pswd|secret' test_cases.txt > passwords.txt
```
Replace all passwords/secrets with real values and use [create_files_from_lines.sh](./create_files_from_lines.sh) to create java files