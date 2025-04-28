# PCRE Regex to GitHub Custom Patterns
## regex-pass - Passwords
```js
// Secret format
(?i)\s*(password|passwd|pwd|pswd|pswrd|pass|pwrd|_password)\b\s*[:=]\s*["']?([A-Za-z0-9!@#$%^&*()_+.\-]+)["']?

// Before Secret
(^|\s)
// After Secret
(\s|$)
```
## regex-secrets - Keys
```js
// Secret format
(?i)(?:sensitive_key|private_key|access_key|application_key|app_key|secret_key|secret-key|client_secret|api_key|app_secret|google_maps_api_key)[\s=:\-]*["']?([a-zA-Z0-9\-_=!]{10,})["']?

// Default before & after secret
```

## EC & DSA Private_Key
```js
// Secret format
[-]{5}BEGIN[[:space:]](?:DSA|EC)[[:space:]]PRIVATE[[:space:]]KEY(?:[[:space:]]BLOCK)?[-]{5}
```

## jdbc_connection_string
```js
// Secret format
\bjdbc:oracle:thin:[^/]+/[^@]+@[a-zA-Z0-9.-]+:\d+[:/][a-zA-Z0-9._-]+\b
```

## connection_string
```js
// Secret format
[a-zA-Z0-9._%+-]+:[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+(\.[a-zA-Z]{2,})?

// Additional secret format - must not match
^(mailto:|sip:)
```
