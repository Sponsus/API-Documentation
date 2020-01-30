---
title: API Reference

language_tabs: # must be one of https://git.io/vQNgJ
  - shell

toc_footers:
  - <a href='https://sponsus.org/developers/oauth'>Create an OAuth app</a>

includes:
  - errors

search: true
---

# Introduction

![](https://media.discordapp.net/attachments/390248379965505546/672286691339534336/unknown.png)

Sponsus empowers the next generation of creators by providing a way for them to get the resources they need. With a flexible monthly or single-time payment model, you can exchange exclusive content for funds.

This is a win-win for everyone, creators get the funds they deserve while keeping their creative freedom and fans get to support the creators they love, knowing that their money is helping to change lives. 

# Authentication

> To authorize, use this code:

```shell
# With shell, you can just pass the correct header with each request
curl "api_endpoint_here"
  -H "Authorization: api_key"
```

> Make sure to replace `api_key` with your API key.

Sponsus uses API keys to allow access to the API. You can create a new API key [here](https://sponsus.org/developers/keys)
For all requests that feature `@me` or are personal to the account holder, Sponsus expects the Authorization header to be set like this:
`Authorization: api_key`

<aside class="notice">
  You must replace <code>api_key</code> with your personal API key.
</aside>

# Using the API

```http
POST "https://api.sponsus.org/v1/profiles/@me"
```
> Will return an error if you did not set your Authorization header correctly

```json
{
  "success": false,
  "error": "Authorization header not found in request"
}
```

When the API responds to your command, it will always return a field called `success`. This field is used to know if a request was successful or not.
The API base URL is `https://api.sponsus.org`. It features a versioning system that allows you to upgrade and downgrade as needed. When we are forcing an upgrade, we will give plenty of warning. 

The full URL is:

`https://api.sponsus.org/v1/<route here>`

For example:

`https://api.sponsus.org/v1/profiles/<userID>/avatar`

# Changelog

### 09/05/19 - Updated the docs
Added more information about the profile objects as well as some routes that might be useful with this object. Added documentation about the Profile getter as well as a private endpoint for finding the Sponsorship status of a user. Requires your API token.

### 09/05/19 - Change to Profile responses
Profile responses have been fixed to only return the fields as noted in the docs. There was an issue where old Profile objects still had old fields that were no longer being used.

# OAuth

>  The implicit grant (response type "token") and other response types
>  causing the authorization server to issue access tokens in the
>  authorization response are vulnerable to access token leakage and
>  access token replay as described in Section 3.1, Section 3.2,
>  Section 3.3, and Section 3.6.
>
>  In order to avoid these issues, Clients SHOULD NOT use the implicit
>  grant and any other response type causing the authorization server to
>  issue an access token in the authorization response.
> <br />- *OAuth 2.0 Security Best Current Practice, Nov 2018*

OAuth is a simple way to publish and interact with protected data. It's also a safer and more secure way for people to give you access. We've kept it simple to save you time. 

We do not support the implict flow as it is insecure. As stated in "OAuth 2.0 Security Best Current Practice". Our priority is user security and using an insecure method of logging is something we dont want to allow

Read more about it [here](https://tools.ietf.org/html/draft-ietf-oauth-security-topics-09#section-2.1.2)

### OAuth URLs
URL | Description
--- | -----------
/oauth/authorize | 	Base authorization URL
/oauth/token | Token URL
/oauth/token/revoke | Revoke an access_token

## 1) Create an application

Before you can connect your website to Sponsus, you need to create an application. [Click here to go there now](https://sponsus.org/developers/oauth).
Keep hold of the client ID and client secret as these will be needed to verify things later


## 2) Redirect to our OAuth url

> To authorize, use this url:

```http
GET https://sponsus.org/oauth/authorize
    ?response_type=code
    &client_id=<clientID>
    &redirect_uri=<one of your redirect URIs listed in your app>
    &scope=identify,sponsoring
```

> Make sure to fill in your details before redirecting the user to this url!

Once the application has been made, we can start to get users connected to your website in no time! 
If you need help generating this url, there is a tool that generates this for you in the OAuth [application edit page](https://sponsus.org/developers/oauth). 

### HTTP Request

`GET https://sponsus.org/oauth/authorize`

### Query Parameters

Parameter | Description
--------- | -----------
***Required*** <br /> response_type | OAuth grant type. Set this to code.
***Required*** <br /> client_id | Your client ID
***Required*** <br /> redirect_uri | One of your redirect_uris that you provided in step 1
***Required (at least one)*** <br /> scope | This parameter will allow your app to read/write to the given scope. For a list of valid scopes, [click here!](#scopes). It will be displayed to the user in human-friendly terms when signing in.
state | This will be added to the redirect URI when the user has authorized or denied the OAuth flow.

### An example of the page you should get:
![](/images/oauth_2_example.png)

If you see this page, that means that all checks have passed and the user is allowed to authorize this app.

## 3) Handle the OAuth callback

> An example redirect URL:

```http
GET https://example.com/callback
    ?code=<code>
    &state=<state>
```

Once the user has authorized (or denied) the OAuth request, they are redirected back to the site defined under `redirect_uri`.
This redirect will have some parameters that you need to complete the OAuth flow such as the `code` and your `state` if you set that during step 2

### Query Parameters

Parameter | Description
--------- | -----------
code | The temporary authorization code that is given back to us in step 4<br>Be aware that this has a expire time of 1 minute
state | If set during step 2, this can be a way of identifying a request or user


## 4) Validate the OAuth code

> OAuth access token retrevial

```http
POST https://api.sponsus.org/v1/oauth/token

code=<code param from step 3>
&grant_type=authorization_code
&client_id=<client ID>
&client_secret=<client secret>
&redirect_uri=<redirect_uri that was used in step 2>
```

> The API will respond with this if the request was successful

```json
{
    "access_token": "3AQQoI56Z1CEDC7F3SVjfkQ892AVvvOj",
    "refresh_token": "Vm8hrWGtkgNEVqKDRVt9bv1Ff6jvfLXp",
    "scope": [
        "identify",
        "sponsoring"
    ],
    "expires_in": 2592000,
    "success": true
}
```

Make sure to also include this header: `Content-Type: application/x-www-form-urlencoded`

<aside class="warning">
  In accordance with RFC 6749, the token URL only accepts a content type of x-www-form-urlencoded. JSON content is not permitted and will return an error.
</aside>

Your server should handle GET requests in Step 3 by performing the following request on the server (not as a redirect):

### HTTP Request

`POST https://api.sponsus.org/v1/oauth/token`

**Please note that anything past this point is part of the API and must use the API url**

### Query Parameters

Parameter | Description
--------- | -----------
***Required*** <br /> code | The code you got from the redirect in step 3
***Required*** <br /> grant_type | Set this to `authorization_code`
***Required*** <br /> client_id | Your client ID
***Required*** <br /> client_secret | Your client secret
***Required*** <br /> redirect_uri | The redirect URI you used for step 2

## 5) Using the access_token

> Example usage

```shell
curl "https://api.sponsus.org/v1/oauth/@me/profile"
  -H "Authorization: Bearer <access_token>"
```

> Read the documentation for the OAuth API [here](#oauth-endpoints)

Now that you have an access token, you can use any of the OAuth routes while using that as the `Authorization` token.

<aside class="notice">
    Any endpoints with `@me` in the route mean that you can only edit the owner of the access token. This is a security measure done across the entire Sponsus API
</aside>

## Keeping in touch

> OAuth access token refresh<br/>Note the change in grant_type to "refresh_token"

```http
POST https://api.sponsus.org/v1/oauth/token

refresh_token=<refresh_token from step 3>
&grant_type=refresh_token
&client_id=<client ID>
&client_secret=<client secret>
&redirect_uri=<redirect_uri that was used in step 2>
```

> The API will respond with this if the request was successful

```json
{
    "access_token": "3AQQoI56Z1CEDC7F3SVjfkQ892AVvvOj",
    "refresh_token": "Vm8hrWGtkgNEVqKDRVt9bv1Ff6jvfLXp",
    "scope": [
        "identify",
        "sponsoring"
    ],
    "expires_in": 2592000,
    "success": true
}
```

> The token the refresh is for will be deleted from the API and forgotten


Access tokens have a lifetime of 1 month and once that time has ran out it is no longer useable. If you wish to keep providing services for the access token you can request a new one using the `refresh_token` you got given during step 4.

## Logging out

> OAuth access token revoke

```http
POST https://api.sponsus.org/v1/oauth/token/revoke

access_token=<the users access token>
&client_id=<client ID>
&client_secret=<client secret>
```

> The API will respond with this if the request was successful

```json
{
    "success": true
}
```

> The token will be deleted from our servers


# OAuth Endpoints

## Authentication

> Example of an OAuth request

```shell
# With shell, you can just pass the correct header with each request
curl "api_endpoint_here"
  -H "Authorization: access_token"
```

This collection of routes is for endpoints related to the OAuth login system. You must use a VALID OAuth access token from Sponsus that is also not expired.
To get an access_token for use with Sponsus, please use the authorization code flow shown [here](#oauth). 

## Get Profile

```shell
curl "https://api.sponsus.org/v1/oauth/@me/profile"
  -H "Authorization: Bearer <access_token>"
```

> If the request was successful, you should see something similar to this:

```json
{
    "success": true,
    "profile": {
        "description": ":ghost: I need to set a description!",
        "about": "I have no description! I should go to my dashboard...",
        "status": "public",
        "username": "OAuthTest",
        "_id": "1737920327297667072"
    }
}
```

This endpoint gets the current logged in users [Profile](#profile) object. 

As with all endpoints in this collection, this request will return a JSON formatted response. If the field `success` is `false`, then there is a field called `error` which denotes what happened and what went wrong with your request

### Scopes
This endpoint requires the following scopes: `identify`

# API: Profiles

## Get Profile

```http
GET "https://api.sponsus.org/v1/profiles/<userID OR unique_url>"

e.g. GET "https://api.sponsus.org/v1/profiles/cerulean"
```

> If the request was successful, you should see something similar to this:

```json
{
    "success": true,
    "profile": {
        "description": ":ghost: I need to set a description!",
        "about": "I have no description! I should go to my dashboard...",
        "status": "public",
        "username": "Cerulean",
        "_id": "1737920327297667072"
    }
}
```

Get a users profile information. This is public information and does not require authentication.


# API: Payments

This area is all about the payment system which includes donations, tiers, sponsorships and more.

## Get User's sponsorship status

```http
GET "https://api.sponsus.org/v1/payments/<userID>/sponsoring"
    Headers:
        Authorization: <API Token>
```

> If the request was successful, you should see something similar to this:

```json
{
    "success": true,
    "sponsorship": {
        "userID": 1737920327297667072,
        "created_at": 1557425238.9788720608,
        "targetID": 1729788214794915840,
        "is_active": true,
        "tier": {
            "_id": 1736611689748631552,
            "title": "Tier title!",
            "price": 1,
            "description": "Sponsor me and get really cool reward...",
            "userID": 1729788214794915840,
            "advanced": {},
            "created_at": 1557014705.5216090679,
            "is_active": true
        },
        "has_paid": true,
        "active_sponsorship_total": 50,
        "active_total": 55
    }
}
```

> Active donations can be grabbed by adding ?include_donations=true to the end of the URL

```json
...
"has_paid": true,
"donations": {
    "total": 50,
    "active_amount": 5
}
```

<aside class="notice">
    You are going to need to set the Authentication header for this to work!
</aside>

This will get the users sponsorship status with you. Requires your API token in order to get the sponsorship status.

### Query params

Name | Description 
---- | -----------
include_donations | Includes an `active_donations` field which denotes how much this user has donated to you as well as any donations that are still vaid as set by your dashboard.

### Examples

Replace \<userID> with the ID of the user you wish to grab the information for.

`GET https://api.sponsus.org/v1/payments/<userID>/sponsoring?include_donations=true`<br/>
`GET https://api.sponsus.org/v1/payments/<userID>/sponsoring`<br/>---


# 🔧 API Reference
 
Everything past this point is the API reference. You can find the OpenAPI 3 spec that this was generated from [here](https://github.com/Sponsus/API-Documentation/blob/master/spec/openapi3.yaml)

**Thank you for using Sponsus!**<h1 id="sponsus-api-profile">profile</h1>

## Get a creators amount per month

<a id="opIdprofile.calc_per_month.get"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/profiles/{userID}/per_month', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/profiles/{userID}/per_month
</p>

Get

<h3 id="get-a-creators-amount-per-month-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "total": 10,
  "sponsors": 2
}
```

<h3 id="get-a-creators-amount-per-month-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[profile.calc_per_month.getResponse](#schemaprofile.calc_per_month.getresponse)|

<aside class="success">
This operation does not require authentication
</aside>

## Get a creators post tags

<a id="opIdprofile.get_post_tags"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/profiles/{userID}/post_tags', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/profiles/{userID}/post_tags
</p>

Get a creators post tags

<h3 id="get-a-creators-post-tags-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{}
```

<h3 id="get-a-creators-post-tags-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[profile.get_post_tagsResponse](#schemaprofile.get_post_tagsresponse)|

<aside class="success">
This operation does not require authentication
</aside>

## profile.get_post_total

<a id="opIdprofile.get_post_total"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/profiles/{userID}/post_total', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/profiles/{userID}/post_total
</p>

Gets a total of all posts released by this creator (for use in the frontend)

<h3 id="profile.get_post_total-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": "string",
  "total": 0
}
```

<h3 id="profile.get_post_total-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[profile.get_post_totalResponse](#schemaprofile.get_post_totalresponse)|

<aside class="success">
This operation does not require authentication
</aside>

## Get a creators profile

<a id="opIdprofile.get_profile"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/profiles/{userID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/profiles/{userID}
</p>

Get a creators profile

<h3 id="get-a-creators-profile-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": "string",
  "profile": {
    "_id": "string",
    "about": "string",
    "status": "string",
    "theme": "string",
    "tags": [
      "string"
    ],
    "is_nsfw": "string",
    "cards": [
      {}
    ],
    "nickname": "string",
    "username": "string"
  }
}
```

<h3 id="get-a-creators-profile-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[profile.get_user_profileResponse](#schemaprofile.get_user_profileresponse)|

<aside class="success">
This operation does not require authentication
</aside>

## profile.get_set_user_profile.post

<a id="opIdprofile.user_profile.post"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
}

r = requests.post('https://api.sponsus.org/v1/profiles/@me', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/profiles/@me
</p>

Requires profile.profile.write

> Body parameter

```json
{
  "nickname": "string",
  "about": "string",
  "description": "string",
  "cards": [
    {
      "title": "string",
      "content": "string",
      "image": "string",
      "link": "string"
    }
  ],
  "theme": "string",
  "is_nsfw": true,
  "tags": [
    "string"
  ]
}
```

<h3 id="profile.get_set_user_profile.post-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|You can send a minimum of 1 field to update. This will only update fields present in the the request.|
|» nickname|body|string|false|none|
|» about|body|string|false|none|
|» description|body|string|false|none|
|» cards|body|[object]|false|none|
|»» title|body|string|false|none|
|»» content|body|string|false|none|
|»» image|body|string|false|none|
|»» link|body|string|false|none|
|» theme|body|string|false|none|
|» is_nsfw|body|boolean|false|none|
|» tags|body|[string]|false|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="profile.get_set_user_profile.post-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="success">
This operation does not require authentication
</aside>

## Get a user's avatar's info

<a id="opIdprofile.get_user_avatar_info"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/profiles/{userID}/avatar/info', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/profiles/{userID}/avatar/info
</p>

This is used to check if an avatar is a video or image. The `key` param is used to beat caching while giving us caching for this specific key.

<h3 id="get-a-user's-avatar's-info-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "is_image": "string",
  "key": "string"
}
```

<h3 id="get-a-user's-avatar's-info-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[profile.get_user_avatar_infoResponse](#schemaprofile.get_user_avatar_inforesponse)|

<aside class="success">
This operation does not require authentication
</aside>

## profile.get_user_avatar_with_key.get

<a id="opIdprofile.get_user_avatar_with_key.get"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/profiles/avatar/{key}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/profiles/avatar/{key}
</p>

Returns an image suitable for your device (WebP for those who support it, PNG for those who cant)

<h3 id="profile.get_user_avatar_with_key.get-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|key|path|string|true|none|

> Example responses

> 200 Response

```json
{}
```

<h3 id="profile.get_user_avatar_with_key.get-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="profile.get_user_avatar_with_key.get-responseschema">Response Schema</h3>

Status Code **200**

*OK*

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|

<aside class="success">
This operation does not require authentication
</aside>

## Get a creator's avatar

<a id="opIdprofile.avatar"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/octet-stream'
}

r = requests.get('https://api.sponsus.org/v1/profiles/{userID}/avatar/{key}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/profiles/{userID}/avatar/{key}
</p>

Returns an image suitable for your device (WebP for those who support it, PNG for those who cant)

<h3 id="get-a-creator's-avatar-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|
|key|path|string|true|none|

> Example responses

> 200 Response

<h3 id="get-a-creator's-avatar-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|string|

<aside class="success">
This operation does not require authentication
</aside>

## Get a creator's background

<a id="opIdprofile.background"></a>

> Code samples

```python
import requests

r = requests.get('https://api.sponsus.org/v1/profiles/{userID}/background')

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/profiles/{userID}/background
</p>

Returns an image suitable for your device (WebP for those who support it, PNG for those who cant)

<h3 id="get-a-creator's-background-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

<h3 id="get-a-creator's-background-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Returns an image object|None|

<aside class="success">
This operation does not require authentication
</aside>

## Update a creator's avatar

<a id="opIdprofile.upload_user_avatar"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'multipart/form-data',
  'Accept': 'application/json'
}

r = requests.post('https://api.sponsus.org/v1/profiles/@me/avatar/upload', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/profiles/@me/avatar/upload
</p>

Requires profile.manage_images.write

> Body parameter

```yaml
file: string

```

<h3 id="update-a-creator's-avatar-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|none|
|» file|body|string(binary)|false|The new avatar in file form|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="update-a-creator's-avatar-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="success">
This operation does not require authentication
</aside>

## Update a creator's background

<a id="opIdprofile.upload_user_background"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
}

r = requests.post('https://api.sponsus.org/v1/profiles/@me/background/upload', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/profiles/@me/background/upload
</p>

Requires profile.manage_images.write

> Body parameter

```json
{
  "file": "string"
}
```

<h3 id="update-a-creator's-background-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|none|
|» file|body|string|false|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="update-a-creator's-background-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|The was an error while uploading|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="success">
This operation does not require authentication
</aside>

<h1 id="sponsus-api-posts">posts</h1>

## Create a post

<a id="opIdposts.create_a_post"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/posts/@me', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/posts/@me
</p>

Creates a new post

> Body parameter

```json
{
  "type": "string",
  "title": "string",
  "price_to_view": "string",
  "content": "string",
  "showing": "string",
  "publish_at": "2020-01-30T10:23:26Z",
  "image": {
    "src": [
      "string"
    ]
  },
  "video": {
    "src": "string"
  },
  "audio": {
    "src": "string",
    "cover_image": "string",
    "background_image": "string",
    "include_in_rss": "string",
    "title": "string"
  },
  "nsfw": "string",
  "is_hidden": "string",
  "tags": "string",
  "attachments": "string",
  "destination": "string"
}
```

<h3 id="create-a-post-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|If you set the type to something other than text, then the corresponding object must be included! If type is audio, for example, then the audio object **must** be present.|
|» type|body|string|false|Must be either text, video, audio, or image|
|» title|body|string|true|none|
|» price_to_view|body|string|true|none|
|» content|body|string|true|none|
|» showing|body|string|false|none|
|» publish_at|body|string(date-time)|false|If included, must be a UTC ISO formatted datetime string. For example: 2020-01-21T00:00:00.000Z|
|» image|body|object|false|none|
|»» src|body|[string]|false|none|
|» video|body|object|false|none|
|»» src|body|string|false|none|
|» audio|body|object|false|none|
|»» src|body|string|false|none|
|»» cover_image|body|string|false|none|
|»» background_image|body|string|false|none|
|»» include_in_rss|body|string|false|none|
|»» title|body|string|false|none|
|» nsfw|body|string|false|none|
|» is_hidden|body|string|false|none|
|» tags|body|string|false|none|
|» attachments|body|string|false|none|
|» destination|body|string|false|The user ID of where you want to send this post. Defaults to your account.|

> Example responses

> 201 Response

```json
{
  "success": true,
  "postID": "string",
  "post_slug": "string",
  "post_url": "string"
}
```

<h3 id="create-a-post-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Created|Inline|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIError](#schemaapierror)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|Forbidden|[APIError](#schemaapierror)|

<h3 id="create-a-post-responseschema">Response Schema</h3>

Status Code **201**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» postID|string|false|none|none|
|» post_slug|string|false|none|none|
|» post_url|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Get a creator's posts

<a id="opIdposts.get_posts"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/posts/{userID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/posts/{userID}
</p>

Gets a creators **public** posts.

<h3 id="get-a-creator's-posts-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": "string",
  "posts": [
    {
      "_id": "string",
      "_id_str": "string",
      "title_slug": "string",
      "type": "string",
      "title": "string",
      "price_to_view": 0,
      "authorID_str": "string",
      "authorID": "string",
      "userID_str": "string",
      "userID": "string",
      "created_at": 0,
      "published_at": 0,
      "is_nsfw": true,
      "is_hidden": true,
      "tags": [
        "string"
      ],
      "comment_count": 0,
      "can_edit": true,
      "content": "string",
      "images": [
        "string"
      ],
      "audio": {
        "src": "string",
        "cover_image": "string",
        "background_image": "string",
        "include_in_rss": "string",
        "title": "string"
      },
      "video": "string"
    }
  ]
}
```

<h3 id="get-a-creator's-posts-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Not Found|[APIError](#schemaapierror)|

<h3 id="get-a-creator's-posts-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» posts|[oneOf]|false|none|none|

*oneOf*

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|»» *anonymous*|[Post](#schemapost)|false|none|Fields with _str are from an old converter that ensures that the front end can read these fields. Please ignore them and use the normal fields! <3|
|»»» _id|string|false|none|none|
|»»» _id_str|string|false|none|none|
|»»» title_slug|string|false|none|none|
|»»» type|string|false|none|none|
|»»» title|string|false|none|none|
|»»» price_to_view|number|false|none|none|
|»»» authorID_str|string|false|none|none|
|»»» authorID|string|false|none|none|
|»»» userID_str|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» created_at|number|false|none|none|
|»»» published_at|number|false|none|none|
|»»» is_nsfw|boolean|false|none|none|
|»»» is_hidden|boolean|false|none|none|
|»»» tags|[string]|false|none|none|
|»»» comment_count|number|false|none|none|
|»»» can_edit|boolean|false|none|none|
|»»» content|string|false|none|none|
|»»» images|[string]|false|none|none|
|»»» audio|object|false|none|none|
|»»»» src|string|false|none|none|
|»»»» cover_image|string|false|none|none|
|»»»» background_image|string|false|none|none|
|»»»» include_in_rss|string|false|none|none|
|»»»» title|string|false|none|none|
|»»» video|string|false|none|none|

*xor*

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|»» *anonymous*|[LockedPost](#schemalockedpost)|false|none|none|
|»»» _id|string|false|none|none|
|»»» _id_str|string|false|none|none|
|»»» title_slug|string|false|none|none|
|»»» type|string|false|none|none|
|»»» title|string|false|none|none|
|»»» price_to_view|number|false|none|none|
|»»» authorID_str|string|false|none|none|
|»»» authorID|string|false|none|none|
|»»» userID_str|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» created_at|number|false|none|none|
|»»» published_at|number|false|none|none|
|»»» is_nsfw|boolean|false|none|none|
|»»» is_hidden|boolean|false|none|none|
|»»» tags|[string]|false|none|none|
|»»» comment_count|number|false|none|none|
|»»» can_edit|boolean|false|none|none|
|»»» locked|number|false|none|none|
|»»» payment_error|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Get a single post from a creator

<a id="opIdposts.get_post.get"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/posts/{userID}/post/{postID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/posts/{userID}/post/{postID}
</p>

<h3 id="get-a-single-post-from-a-creator-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|
|postID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "post": {
    "_id": "string",
    "_id_str": "string",
    "title_slug": "string",
    "type": "string",
    "title": "string",
    "price_to_view": 0,
    "authorID_str": "string",
    "authorID": "string",
    "userID_str": "string",
    "userID": "string",
    "created_at": 0,
    "published_at": 0,
    "is_nsfw": true,
    "is_hidden": true,
    "tags": [
      "string"
    ],
    "comment_count": 0,
    "can_edit": true,
    "content": "string",
    "images": [
      "string"
    ],
    "audio": {
      "src": "string",
      "cover_image": "string",
      "background_image": "string",
      "include_in_rss": "string",
      "title": "string"
    },
    "video": "string"
  }
}
```

<h3 id="get-a-single-post-from-a-creator-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Not Found|[APIError](#schemaapierror)|

<h3 id="get-a-single-post-from-a-creator-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» post|any|false|none|none|

*oneOf*

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|»» *anonymous*|[Post](#schemapost)|false|none|Fields with _str are from an old converter that ensures that the front end can read these fields. Please ignore them and use the normal fields! <3|
|»»» _id|string|false|none|none|
|»»» _id_str|string|false|none|none|
|»»» title_slug|string|false|none|none|
|»»» type|string|false|none|none|
|»»» title|string|false|none|none|
|»»» price_to_view|number|false|none|none|
|»»» authorID_str|string|false|none|none|
|»»» authorID|string|false|none|none|
|»»» userID_str|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» created_at|number|false|none|none|
|»»» published_at|number|false|none|none|
|»»» is_nsfw|boolean|false|none|none|
|»»» is_hidden|boolean|false|none|none|
|»»» tags|[string]|false|none|none|
|»»» comment_count|number|false|none|none|
|»»» can_edit|boolean|false|none|none|
|»»» content|string|false|none|none|
|»»» images|[string]|false|none|none|
|»»» audio|object|false|none|none|
|»»»» src|string|false|none|none|
|»»»» cover_image|string|false|none|none|
|»»»» background_image|string|false|none|none|
|»»»» include_in_rss|string|false|none|none|
|»»»» title|string|false|none|none|
|»»» video|string|false|none|none|

*xor*

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|»» *anonymous*|[LockedPost](#schemalockedpost)|false|none|none|
|»»» _id|string|false|none|none|
|»»» _id_str|string|false|none|none|
|»»» title_slug|string|false|none|none|
|»»» type|string|false|none|none|
|»»» title|string|false|none|none|
|»»» price_to_view|number|false|none|none|
|»»» authorID_str|string|false|none|none|
|»»» authorID|string|false|none|none|
|»»» userID_str|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» created_at|number|false|none|none|
|»»» published_at|number|false|none|none|
|»»» is_nsfw|boolean|false|none|none|
|»»» is_hidden|boolean|false|none|none|
|»»» tags|[string]|false|none|none|
|»»» comment_count|number|false|none|none|
|»»» can_edit|boolean|false|none|none|
|»»» locked|number|false|none|none|
|»»» payment_error|string|false|none|none|

<aside class="success">
This operation does not require authentication
</aside>

## Delete a post

<a id="opIdposts.get_post.delete"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/posts/{userID}/post/{postID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/posts/{userID}/post/{postID}
</p>

Requires posts.manage_posts.write

<h3 id="delete-a-post-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|
|postID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="delete-a-post-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Update a post

<a id="opIdposts.get_post.post"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/posts/{userID}/post/{postID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/posts/{userID}/post/{postID}
</p>

Requires posts.manage_posts.write

> Body parameter

```json
{
  "title": "string",
  "content": "string",
  "price_to_view": "string",
  "audio": {
    "src": "string",
    "cover_image": "string",
    "background_image": "string",
    "include_in_rss": "string",
    "title": "string"
  },
  "video": {
    "src": "string"
  },
  "destination": "string",
  "attachments": "string",
  "tags": "string",
  "is_hidden": "string",
  "nsfw": "string",
  "image": {
    "src": [
      "string"
    ]
  },
  "publish_at": "2020-01-30T10:23:26Z",
  "showing": "string",
  "type": "string"
}
```

<h3 id="update-a-post-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|
|postID|path|string|true|none|
|body|body|object|false|If you set the type to something other than text, then the corresponding object must be included! If type is audio, for example, then the audio object **must** be present.|
|» title|body|string|true|none|
|» content|body|string|true|none|
|» price_to_view|body|string|true|none|
|» audio|body|object|false|none|
|»» src|body|string|false|none|
|»» cover_image|body|string|false|none|
|»» background_image|body|string|false|none|
|»» include_in_rss|body|string|false|none|
|»» title|body|string|false|none|
|» video|body|object|false|none|
|»» src|body|string|false|none|
|» destination|body|string|false|The user ID of where you want to send this post. Defaults to your account.|
|» attachments|body|string|false|none|
|» tags|body|string|false|none|
|» is_hidden|body|string|false|none|
|» nsfw|body|string|false|none|
|» image|body|object|false|none|
|»» src|body|[string]|false|none|
|» publish_at|body|string(date-time)|false|If included, must be a UTC ISO formatted datetime string. For example: 2020-01-21T00:00:00.000Z|
|» showing|body|string|false|none|
|» type|body|string|true|Must be either text, video, audio, or image|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="update-a-post-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Publish a post

<a id="opIdposts.publish_post"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/posts/{userID}/post/{postID}/publish', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/posts/{userID}/post/{postID}/publish
</p>

Publishes a previously hidden post for viewing by either sponsors or the public. This will trigger all after-publish hooks such as notifications. **This can only be done once per post and is not reversable.**

<h3 id="publish-a-post-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|
|postID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="publish-a-post-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|The requested post does not exist|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## List a post's secret keys

<a id="opIdposts.list_secret_keys"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/posts/@me/post/{postID}/secret_keys', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/posts/@me/post/{postID}/secret_keys
</p>

Requires posts.secret_keys.read

<h3 id="list-a-post's-secret-keys-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "keys": [
    {
      "_id": "string",
      "authorID": "string",
      "name": "string",
      "postID": "string",
      "code": "string",
      "uses": 0,
      "expires_at": 0,
      "created_at": 0,
      "views": 0
    }
  ]
}
```

<h3 id="list-a-post's-secret-keys-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="list-a-post's-secret-keys-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» keys|[[SecretKey](#schemasecretkey)]|false|none|[A secret key used to view posts]|
|»» SecretKey|[SecretKey](#schemasecretkey)|false|none|A secret key used to view posts|
|»»» _id|string|false|none|none|
|»»» authorID|string|false|none|none|
|»»» name|string|false|none|none|
|»»» postID|string|false|none|none|
|»»» code|string|false|none|none|
|»»» uses|number|false|none|none|
|»»» expires_at|number|false|none|none|
|»»» created_at|number|false|none|none|
|»»» views|number|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Create a new secret key

<a id="opIdposts.create_secret_key"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/posts/@me/post/{postID}/secret_keys', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/posts/@me/post/{postID}/secret_keys
</p>

Requires posts.secret_keys.write

> Body parameter

```json
{
  "name": "string",
  "uses": 0,
  "expires_at": "2020-01-30T10:23:26Z"
}
```

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<name>string</name>
<uses>0</uses>
<expires_at>2020-01-30T10:23:26Z</expires_at>
```

<h3 id="create-a-new-secret-key-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|
|body|body|object|false|none|
|» name|body|string|true|none|
|» uses|body|number|true|none|
|» expires_at|body|string(date-time)|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "key": {
    "_id": "string",
    "authorID": "string",
    "name": "string",
    "postID": "string",
    "code": "string",
    "uses": 0,
    "expires_at": 0,
    "created_at": 0,
    "views": 0
  }
}
```

<h3 id="create-a-new-secret-key-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Returns the newly created key|Inline|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<h3 id="create-a-new-secret-key-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» key|[SecretKey](#schemasecretkey)|false|none|A secret key used to view posts|
|»» _id|string|false|none|none|
|»» authorID|string|false|none|none|
|»» name|string|false|none|none|
|»» postID|string|false|none|none|
|»» code|string|false|none|none|
|»» uses|number|false|none|none|
|»» expires_at|number|false|none|none|
|»» created_at|number|false|none|none|
|»» views|number|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Delete a secret key

<a id="opIdposts.delete_secret_key"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/posts/@me/post/{postID}/secret_keys/{keyID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/posts/@me/post/{postID}/secret_keys/{keyID}
</p>

Delete a secret key

<h3 id="delete-a-secret-key-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|
|keyID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="delete-a-secret-key-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|The key is deleted|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

<h1 id="sponsus-api-payments">payments</h1>

## Create a new tier

<a id="opIdpayments.manage_tiers.post"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/payments/@me/tiers', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/payments/@me/tiers
</p>

Requires payments.tiers.write

> Body parameter

```json
{
  "title": "string",
  "description": "string",
  "price": 0
}
```

<h3 id="create-a-new-tier-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|none|
|» title|body|string|false|none|
|» description|body|string|false|none|
|» price|body|number|false|none|

> Example responses

> 201 Response

```json
{
  "success": "string",
  "tier": {
    "_id": "string",
    "title": "string",
    "price": 0,
    "description": "string",
    "userID": "string",
    "advanced": {},
    "created_at": 0,
    "support": {
      "is_supporting": true
    }
  }
}
```

<h3 id="create-a-new-tier-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Returns the created tier|Inline|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<h3 id="create-a-new-tier-responseschema">Response Schema</h3>

Status Code **201**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» tier|[Tier](#schematier)|false|none|A tier for a creator.|
|»» _id|string|true|none|none|
|»» title|string|true|none|none|
|»» price|number|true|none|none|
|»» description|string|true|none|none|
|»» userID|string|true|none|none|
|»» advanced|object|false|none|none|
|»» created_at|number|false|none|none|
|»» support|[Support](#schemasupport)|false|none|none|
|»»» is_supporting|boolean|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Get your tiers

<a id="opIdpayments.manage_tiers.get"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/payments/@me/tiers', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/payments/@me/tiers
</p>

Requires payments.tiers.read

> Example responses

> 200 Response

```json
{
  "success": true,
  "tiers": [
    {
      "_id": 1732814647763013600,
      "title": "Sponsor Sponsus!",
      "price": 5,
      "description": "Demo tier!",
      "userID": 1729788214794915800,
      "advanced": {
        "limit": {
          "enabled": true,
          "max": 6
        },
        "discord_role": {
          "name": "Writing Team",
          "id": 622152828831662100
        }
      },
      "created_at": 1556109440
    }
  ]
}
```

> 401 Response

```json
{
  "success": "string",
  "error": "string",
  "code": "string",
  "missing_permission": "string"
}
```

<h3 id="get-your-tiers-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Returns your tiers|Inline|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<h3 id="get-your-tiers-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» tier|[[Tier](#schematier)]|false|none|[A tier for a creator.]|
|»» Tier|[Tier](#schematier)|false|none|A tier for a creator.|
|»»» _id|string|true|none|none|
|»»» title|string|true|none|none|
|»»» price|number|true|none|none|
|»»» description|string|true|none|none|
|»»» userID|string|true|none|none|
|»»» advanced|object|false|none|none|
|»»» created_at|number|false|none|none|
|»»» support|[Support](#schemasupport)|false|none|none|
|»»»» is_supporting|boolean|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Delete a tier

<a id="opIdpayments.manage_tier.delete"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/payments/@me/tiers/{tierID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/payments/@me/tiers/{tierID}
</p>

Delete a tier

<h3 id="delete-a-tier-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|tierID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="delete-a-tier-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Update a tier

<a id="opIdpayments.manage_tier.post"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/payments/@me/tiers/{tierID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/payments/@me/tiers/{tierID}
</p>

Requires payments.tiers.write

> Body parameter

```json
{
  "title": "string",
  "description": "string",
  "advanced": {
    "limit": {
      "enabled": true,
      "max": 0
    },
    "discord_role": {
      "id": "string",
      "name": "string"
    }
  }
}
```

<h3 id="update-a-tier-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|tierID|path|string|true|none|
|body|body|object|false|none|
|» title|body|string|false|none|
|» description|body|string|false|none|
|» advanced|body|object|false|none|
|»» limit|body|object|false|none|
|»»» enabled|body|boolean|false|none|
|»»» max|body|number|false|none|
|»» discord_role|body|object|false|none|
|»»» id|body|string|false|none|
|»»» name|body|string|false|none|

> Example responses

> 200 Response

```json
{}
```

> 401 Response

```json
{
  "success": "string",
  "error": "string",
  "code": "string",
  "missing_permission": "string"
}
```

<h3 id="update-a-tier-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Update successful|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|You do not have permission to write to payments.tiers|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You do not have write access to this tier.|[APIError](#schemaapierror)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Not Found|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## List sponsors

<a id="opIdpayments.list_sponsors"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/search/@me/sponsors', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/search/@me/sponsors
</p>

List all of your sponsors as well as filter them.

<h3 id="list-sponsors-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|tier|query|string|false|The tierID that you wish to filter results from. If present and `tier_only` is not/is false then the price of the tier will be used as a filter instead.|
|username|query|string|false|The username you wish to filter for|
|paid_only|query|string|false|Only returns results for users who have paid in the last month|
|tier_only|query|string|false|Only returns results for users who are sponsoring a tier|

> Example responses

> 200 Response

```json
{
  "success": true,
  "results": [
    {
      "username": "string",
      "_id": "string",
      "cards": [
        {
          "title": "string",
          "content": "string",
          "image": "string",
          "link": "string"
        }
      ],
      "nickname": "string",
      "status": "string",
      "theme": "string",
      "about": "string",
      "description": "string",
      "created_at": "string",
      "tier": {
        "_id": "string",
        "title": "string",
        "price": 0,
        "description": "string",
        "userID": "string",
        "advanced": {},
        "created_at": 0,
        "support": {
          "is_supporting": true
        }
      },
      "total": 0,
      "lifetime": 0
    }
  ]
}
```

<h3 id="list-sponsors-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="list-sponsors-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» results|[object]|false|none|none|
|»» username|string|false|none|none|
|»» _id|string|false|none|none|
|»» cards|[[ProfileCard](#schemaprofilecard)]|false|none|none|
|»»» ProfileCard|[ProfileCard](#schemaprofilecard)|false|none|none|
|»»»» title|string|false|none|none|
|»»»» content|string|false|none|none|
|»»»» image|string|false|none|none|
|»»»» link|string|false|none|none|
|»» nickname|string|false|none|none|
|»» status|string|false|none|none|
|»» theme|string|false|none|none|
|»» about|string|false|none|none|
|»» description|string|false|none|none|
|»» created_at|string|false|none|none|
|»» tier|[Tier](#schematier)|false|none|A tier for a creator.|
|»»» _id|string|true|none|none|
|»»» title|string|true|none|none|
|»»» price|number|true|none|none|
|»»» description|string|true|none|none|
|»»» userID|string|true|none|none|
|»»» advanced|object|false|none|none|
|»»» created_at|number|false|none|none|
|»»» support|[Support](#schemasupport)|false|none|none|
|»»»» is_supporting|boolean|false|none|none|
|»» total|number|false|none|Total this user has sponsored THIS MONTH.|
|»» lifetime|number|false|none|Collective total of all sponsorships this user has paid towards you.|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Get my monthly stats

<a id="opIdpayments.payment_stats"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/payments/@me/statistics', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/payments/@me/statistics
</p>

Requires payments.stats.read
Get the monthly stats for the user.

> Example responses

> 200 Response

```json
{
  "success": true,
  "total": 5,
  "sponsorships": 1,
  "due": 1,
  "sponsoring": 1
}
```

> 403 Response

```json
{
  "success": true,
  "error": "string",
  "code": "string"
}
```

<h3 id="get-my-monthly-stats-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[payments.payment_statsResponse](#schemapayments.payment_statsresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|Forbidden|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Get a creators tiers

<a id="opIdpayments.get_user_tiers"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/payments/{userID}/tiers', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/payments/{userID}/tiers
</p>

Gets the creators tiers for display on the front end. If you want to edit tiers, use /payments/@me/tiers.

<h3 id="get-a-creators-tiers-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "tiers": [
    {
      "_id": 1732814647763013600,
      "title": "Sponsor Sponsus!",
      "price": 5,
      "description": "Testing tier for content and such\n\n**Rewards**\n* Cool role on our **Discord**\n* Hugs from me <3",
      "userID": 1729788214794915800,
      "advanced": {
        "limit": {
          "enabled": true,
          "max": 6
        },
        "discord_role": {
          "name": "Writing Team",
          "id": 622152828831662100
        }
      },
      "created_at": 1556109440
    }
  ]
}
```

<h3 id="get-a-creators-tiers-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|[payments.get_user_tiersResponse](#schemapayments.get_user_tiersresponse)|

<aside class="success">
This operation does not require authentication
</aside>

## Get a single tier

<a id="opIdpayments.get_tier.get"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/payments/{userID}/tiers/{tierID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/payments/{userID}/tiers/{tierID}
</p>

Get a single tier

<h3 id="get-a-single-tier-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|
|tierID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": "string",
  "tier": {
    "_id": "string",
    "title": "string",
    "price": 0,
    "description": "string",
    "userID": "string",
    "advanced": {},
    "created_at": 0,
    "support": {
      "is_supporting": true
    }
  }
}
```

<h3 id="get-a-single-tier-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|[payments.get_tier.getResponse](#schemapayments.get_tier.getresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|The requested tier does not exist|[APIError](#schemaapierror)|

<aside class="success">
This operation does not require authentication
</aside>

## Get a tier's remaining slots (if its a limited tier)

<a id="opIdpayments.get_tier"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/payments/{userID}/tiers/{tierID}/remaining_slots', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/payments/{userID}/tiers/{tierID}/remaining_slots
</p>

Tells you how many slots are open for sponsorships. Used in the UI to show how many are left.

<h3 id="get-a-tier's-remaining-slots-(if-its-a-limited-tier)-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|
|tierID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "total_left": 5
}
```

> 400 Response

```json
{
  "success": true,
  "error": "string",
  "code": "string"
}
```

<h3 id="get-a-tier's-remaining-slots-(if-its-a-limited-tier)-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|[payments.get_tierResponse](#schemapayments.get_tierresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Tier is not limited|[APIError](#schemaapierror)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Tier was not found|[APIError](#schemaapierror)|

<aside class="success">
This operation does not require authentication
</aside>

## List who I am supporting

<a id="opIdpayments.get_user_supporting"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/payments/@me/supporting', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/payments/@me/supporting
</p>

Requires payments.sponsoring.read

> Example responses

> 200 Response

```json
{
  "success": "string",
  "supporting": [
    {
      "tier": {
        "_id": "string",
        "title": "string",
        "price": 0,
        "description": "string",
        "userID": "string",
        "advanced": {},
        "created_at": 0,
        "support": {
          "is_supporting": true
        }
      },
      "price": 0,
      "owner": {
        "_id": "string",
        "about": "string",
        "status": "string",
        "theme": "string",
        "tags": [
          "string"
        ],
        "is_nsfw": "string",
        "cards": [
          {}
        ],
        "nickname": "string",
        "username": "string"
      },
      "is_active": true,
      "is_custom": true,
      "charge_amount": 0
    }
  ]
}
```

<h3 id="list-who-i-am-supporting-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|[payments.get_user_supportingResponse](#schemapayments.get_user_supportingresponse)|

<aside class="success">
This operation does not require authentication
</aside>

## Check if a user is sponsoring you

<a id="opIdpayments.user_sponsoring_status"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/payments/{userID}/sponsoring', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/payments/{userID}/sponsoring
</p>

Gets an IncomingSponsorship object if the target user is sponsoring you.

Requires payments.sponsorships.read

**(Sponsorships and sponsoring are two different permissions!!)**

<h3 id="check-if-a-user-is-sponsoring-you-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "sponsorship": {
    "userID": "string",
    "created_at": 0,
    "is_active": true,
    "targetID": "string",
    "tier": {
      "_id": "string",
      "title": "string",
      "price": 0,
      "description": "string",
      "userID": "string",
      "advanced": {},
      "created_at": 0,
      "support": {
        "is_supporting": true
      }
    },
    "has_paid": true,
    "current_month": "string",
    "is_custom": true,
    "active_total": 0,
    "active_sponsorship_total": 0
  }
}
```

<h3 id="check-if-a-user-is-sponsoring-you-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[payments.get_user_sponsoring_statusResponse](#schemapayments.get_user_sponsoring_statusresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|Forbidden|[APIError](#schemaapierror)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Not Found|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## payments.set_donation_settings

<a id="opIdpayments.set_donation_settings"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/payments/{userID}/donations/settings', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/payments/{userID}/donations/settings
</p>

Get a creators donation settings

<h3 id="payments.set_donation_settings-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "enabled": true,
  "length": "1month",
  "limit": "Thu 13/02/2020",
  "social_media_image": "https://cdn.ceru.tech/sponsus/1729788214794915840/1736565642238234624.png"
}
```

> 404 Response

```json
{
  "success": true,
  "error": "string",
  "code": "string"
}
```

<h3 id="payments.set_donation_settings-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|[payments.set_donation_settingsResponse](#schemapayments.set_donation_settingsresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|User does not exist|[APIError](#schemaapierror)|

<aside class="success">
This operation does not require authentication
</aside>

## payments.get_charges

<a id="opIdpayments.get_charges"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/payments/@me/charges', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/payments/@me/charges
</p>

Requires payments.charges.read

> Example responses

> 200 Response

```json
{
  "success": "string",
  "charges": [
    {
      "_id": "string",
      "amount": "string",
      "destination": {
        "_id": "string",
        "username": "string"
      },
      "created_at": "string",
      "avalible_at": "string",
      "user": {
        "_id": "string",
        "username": "string"
      },
      "type": "string",
      "avalible_percent": "string",
      "created_at_stamp": "string"
    }
  ]
}
```

<h3 id="payments.get_charges-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[payments.get_chargesResponse](#schemapayments.get_chargesresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="success">
This operation does not require authentication
</aside>

<h1 id="sponsus-api-oauth">oauth</h1>

## Get the logged in user's profile

<a id="opIdoauth.oauth_get_profile"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/oauth/@me/profile', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/oauth/@me/profile
</p>

> Example responses

> 200 Response

```json
{
  "success": true,
  "profile": {
    "_id": "string",
    "about": "string",
    "status": "string",
    "theme": "string",
    "tags": [
      "string"
    ],
    "is_nsfw": "string",
    "cards": [
      {}
    ],
    "nickname": "string",
    "username": "string"
  }
}
```

<h3 id="get-the-logged-in-user's-profile-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="get-the-logged-in-user's-profile-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» profile|[Profile](#schemaprofile)|false|none|A profile object used to describe a creator.|
|»» _id|string|false|none|none|
|»» about|string|false|none|none|
|»» status|string|false|none|none|
|»» theme|string|false|none|none|
|»» tags|[string]|false|none|none|
|»» is_nsfw|string|false|none|none|
|»» cards|[object]|false|none|none|
|»» nickname|string|false|none|none|
|»» username|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

<h1 id="sponsus-api-files">files</h1>

## List all files

<a id="opIdfiles.list_files"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/files/@me', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/files/@me
</p>

Requires files.manage_files.read

> Example responses

> OK

```json
{}
```

> 401 Response

```json
{
  "success": "string",
  "error": "string",
  "code": "string",
  "missing_permission": "string"
}
```

<h3 id="list-all-files-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<h3 id="list-all-files-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» files|[[File](#schemafile)]|false|none|none|
|»» File|[File](#schemafile)|false|none|none|
|»»» _id|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» key|string|false|none|none|
|»»» hash|string|false|none|none|
|»»» filename|string|false|none|none|
|»»» filesize|number|false|none|none|
|»»» filesize_human|string|false|none|none|
|»»» created_at|string|false|none|none|
|» total|number|false|none|none|
|» total_human|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Upload a new file

<a id="opIdfiles.upload_file"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'multipart/form-data',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/files/@me', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/files/@me
</p>

Requires files.manage_files.write

> Body parameter

```yaml
file: string

```

<h3 id="upload-a-new-file-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object(binary)|false|Set the file param to the file you want to upload. Must be a binary file, not base64 encoded!!|
|» file|body|string(binary)|false|none|

> Example responses

> 201 Response

```json
{
  "success": true,
  "file": {
    "url": "string"
  }
}
```

<h3 id="upload-a-new-file-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Returns the newly uploaded file in url form.|Inline|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|507|[Insufficient Storage](https://tools.ietf.org/html/rfc2518#section-10.6)|Not enough space on your CDN to upload a new file|[APIError](#schemaapierror)|

<h3 id="upload-a-new-file-responseschema">Response Schema</h3>

Status Code **201**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» file|object|false|none|none|
|»» url|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Delete a file

<a id="opIdfiles.delete_file"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/files/@me/{fileID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/files/@me/{fileID}
</p>

Requires files.manage_files.write

<h3 id="delete-a-file-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|fileID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="delete-a-file-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Deleted the file|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|The requested file does not exist|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

<h1 id="sponsus-api-search">search</h1>

## Search users

<a id="opIdsearch.search_users"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/search', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/search
</p>

> Example responses

> 200 Response

```json
{
  "success": true,
  "results": [
    {
      "_id": "string",
      "about": "string",
      "status": "string",
      "theme": "string",
      "tags": [
        "string"
      ],
      "is_nsfw": "string",
      "cards": [
        {}
      ],
      "nickname": "string",
      "username": "string"
    }
  ]
}
```

<h3 id="search-users-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|You need to give a query to search with! (try ?q=Ceru to search for the founder of Sponsus!)|[APIError](#schemaapierror)|

<h3 id="search-users-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» results|[[Profile](#schemaprofile)]|false|none|[A profile object used to describe a creator.]|
|»» Profile|[Profile](#schemaprofile)|false|none|A profile object used to describe a creator.|
|»»» _id|string|false|none|none|
|»»» about|string|false|none|none|
|»»» status|string|false|none|none|
|»»» theme|string|false|none|none|
|»»» tags|[string]|false|none|none|
|»»» is_nsfw|string|false|none|none|
|»»» cards|[object]|false|none|none|
|»»» nickname|string|false|none|none|
|»»» username|string|false|none|none|

<aside class="success">
This operation does not require authentication
</aside>

<h1 id="sponsus-api-feed">feed</h1>

## List all posts from your sponsorships

<a id="opIdfeed.get_feed"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/feed/@me', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/feed/@me
</p>

> Example responses

> 200 Response

```json
{
  "success": "string",
  "posts": [
    {
      "_id": "string",
      "_id_str": "string",
      "title_slug": "string",
      "type": "string",
      "title": "string",
      "price_to_view": 0,
      "authorID_str": "string",
      "authorID": "string",
      "userID_str": "string",
      "userID": "string",
      "created_at": 0,
      "published_at": 0,
      "is_nsfw": true,
      "is_hidden": true,
      "tags": [
        "string"
      ],
      "comment_count": 0,
      "can_edit": true,
      "content": "string",
      "images": [
        "string"
      ],
      "audio": {
        "src": "string",
        "cover_image": "string",
        "background_image": "string",
        "include_in_rss": "string",
        "title": "string"
      },
      "video": "string"
    }
  ]
}
```

<h3 id="list-all-posts-from-your-sponsorships-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="list-all-posts-from-your-sponsorships-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» posts|[oneOf]|false|none|none|

*oneOf*

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|»» *anonymous*|[Post](#schemapost)|false|none|Fields with _str are from an old converter that ensures that the front end can read these fields. Please ignore them and use the normal fields! <3|
|»»» _id|string|false|none|none|
|»»» _id_str|string|false|none|none|
|»»» title_slug|string|false|none|none|
|»»» type|string|false|none|none|
|»»» title|string|false|none|none|
|»»» price_to_view|number|false|none|none|
|»»» authorID_str|string|false|none|none|
|»»» authorID|string|false|none|none|
|»»» userID_str|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» created_at|number|false|none|none|
|»»» published_at|number|false|none|none|
|»»» is_nsfw|boolean|false|none|none|
|»»» is_hidden|boolean|false|none|none|
|»»» tags|[string]|false|none|none|
|»»» comment_count|number|false|none|none|
|»»» can_edit|boolean|false|none|none|
|»»» content|string|false|none|none|
|»»» images|[string]|false|none|none|
|»»» audio|object|false|none|none|
|»»»» src|string|false|none|none|
|»»»» cover_image|string|false|none|none|
|»»»» background_image|string|false|none|none|
|»»»» include_in_rss|string|false|none|none|
|»»»» title|string|false|none|none|
|»»» video|string|false|none|none|

*xor*

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|»» *anonymous*|[LockedPost](#schemalockedpost)|false|none|none|
|»»» _id|string|false|none|none|
|»»» _id_str|string|false|none|none|
|»»» title_slug|string|false|none|none|
|»»» type|string|false|none|none|
|»»» title|string|false|none|none|
|»»» price_to_view|number|false|none|none|
|»»» authorID_str|string|false|none|none|
|»»» authorID|string|false|none|none|
|»»» userID_str|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» created_at|number|false|none|none|
|»»» published_at|number|false|none|none|
|»»» is_nsfw|boolean|false|none|none|
|»»» is_hidden|boolean|false|none|none|
|»»» tags|[string]|false|none|none|
|»»» comment_count|number|false|none|none|
|»»» can_edit|boolean|false|none|none|
|»»» locked|number|false|none|none|
|»»» payment_error|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Get feed post count

<a id="opIdfeed.get_total_post_count"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/feed/@me/total', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/feed/@me/total
</p>

Used to check if the UI should update

> Example responses

> 200 Response

```json
{
  "s": true,
  "t": 0
}
```

<h3 id="get-feed-post-count-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="get-feed-post-count-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» s|boolean|false|none|Was the request successful or not|
|» t|number|false|none|Number of posts in your feed|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

<h1 id="sponsus-api-chat">chat</h1>

## Create a new conversation

<a id="opIdchat.create_conversation"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/chat/@me/new_conversation', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/chat/@me/new_conversation
</p>

> Body parameter

```json
{
  "users": [
    0
  ]
}
```

<h3 id="create-a-new-conversation-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|none|
|» users|body|[number]|false|An array of a single userID you wish to add. In future, we may allow bigger groups.|

> Example responses

> 200 Response

```json
{
  "success": "string",
  "conversation": {
    "_id": "string",
    "users": "string",
    "created_at": "string",
    "userID": [
      0
    ],
    "is_direct_message": true,
    "title": "string",
    "image": "string",
    "is_active": true
  }
}
```

<h3 id="create-a-new-conversation-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Returns the newly created conversation|Inline|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You or one of your target users has blocked you or you have blocked them|[APIError](#schemaapierror)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|One of the users in the array does not exist, please make sure that they do exist before requesting a conversation.|[APIError](#schemaapierror)|

<h3 id="create-a-new-conversation-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» conversation|[Conversation](#schemaconversation)|false|none|A conversation object for use in the chat system|
|»» _id|string|false|none|none|
|»» users|string|false|none|none|
|»» created_at|string|false|none|none|
|»» userID|[number]|false|none|Array of userIDs in the conversation|
|»» is_direct_message|boolean|false|none|none|
|»» title|string|false|none|none|
|»» image|string|false|none|none|
|»» is_active|boolean|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## List active conversations

<a id="opIdchat.get_conversations"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/chat/@me/conversations', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/chat/@me/conversations
</p>

> Example responses

> 200 Response

```json
{
  "success": true,
  "conversations": [
    {
      "_id": "string",
      "users": "string",
      "created_at": "string",
      "userID": [
        0
      ],
      "is_direct_message": true,
      "title": "string",
      "image": "string",
      "is_active": true
    }
  ]
}
```

<h3 id="list-active-conversations-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="list-active-conversations-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» conversations|[[Conversation](#schemaconversation)]|false|none|[A conversation object for use in the chat system]|
|»» Conversation|[Conversation](#schemaconversation)|false|none|A conversation object for use in the chat system|
|»»» _id|string|false|none|none|
|»»» users|string|false|none|none|
|»»» created_at|string|false|none|none|
|»»» userID|[number]|false|none|Array of userIDs in the conversation|
|»»» is_direct_message|boolean|false|none|none|
|»»» title|string|false|none|none|
|»»» image|string|false|none|none|
|»»» is_active|boolean|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Create RTM url

<a id="opIdchat.create_conversation_rtm_url"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/chat/{convoID}/rtm/start', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/chat/{convoID}/rtm/start
</p>

Requires chat.live_messages.read

An RTM url allows you to listen in on any conversation that you have access to. Just request it, and connect to the provided url via a WebSocket within 1 minute.

<h3 id="create-rtm-url-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|convoID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "rtm": {
    "base_url": "string"
  }
}
```

<h3 id="create-rtm-url-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|The base URL for the RTM session is given below. This can be used to watch for new messages by going to <base_url>/messages. This url only supports WSS connections!|Inline|

<h3 id="create-rtm-url-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» rtm|object|false|none|none|
|»» base_url|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Create unread notifications RTM URL

<a id="opIdchat.create_message_notifications_url"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/chat/@me/rtm/unread/start', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/chat/@me/rtm/unread/start
</p>

Requires chat.manage_messages.read

Creates a unread message notification RTM link which allows you to listen for new messages for all conversations, including ones that get made after the url's creation.

Unlike the conversation RTM link, this one is just a simple "plug the url into a websocket and go" type deal.

> Example responses

> 200 Response

```json
{
  "success": "string",
  "rtm": {
    "base_url": "string"
  }
}
```

<h3 id="create-unread-notifications-rtm-url-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Returns a valid WebSocket URL for listening to unread message events.|Inline|

<h3 id="create-unread-notifications-rtm-url-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» rtm|object|false|none|none|
|»» base_url|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## List a conversation's messages

<a id="opIdchat.manage_messages.get"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/chat/{convoID}/messages', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/chat/{convoID}/messages
</p>

<h3 id="list-a-conversation's-messages-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|convoID|path|string|true|none|
|page|query|number|false|The page you want to pull from|

> Example responses

> 200 Response

```json
{
  "success": true,
  "messages": [
    {
      "_id": "string",
      "convoID": "string",
      "userID": "string",
      "content": "string",
      "created_at": 0,
      "attachments": [
        {
          "url": "string",
          "filename": "string"
        }
      ],
      "is_active": true,
      "is_unread": true
    }
  ],
  "has_more": true
}
```

<h3 id="list-a-conversation's-messages-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Returns the conversations messages sorted by creation. Use the page param to go back in history|Inline|

<h3 id="list-a-conversation's-messages-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» messages|[[ChatMessage](#schemachatmessage)]|false|none|none|
|»» ChatMessage|[ChatMessage](#schemachatmessage)|false|none|none|
|»»» _id|string|false|none|none|
|»»» convoID|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» content|string|false|none|none|
|»»» created_at|number|false|none|none|
|»»» attachments|[[Attachment](#schemaattachment)]|false|none|none|
|»»»» Attachment|[Attachment](#schemaattachment)|false|none|none|
|»»»»» url|string|false|none|none|
|»»»»» filename|string|false|none|none|
|»»» is_active|boolean|false|none|none|
|»»» is_unread|boolean|false|none|none|
|» has_more|boolean|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Create a new message

<a id="opIdchat.create_message"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/chat/{convoID}/messages', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/chat/{convoID}/messages
</p>

Requires chat.manage_messages.write

Creates a new message in the target conversation.

> Body parameter

```json
{
  "content": "string",
  "attachments": [
    {
      "url": "string",
      "filename": "string"
    }
  ]
}
```

<h3 id="create-a-new-message-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|convoID|path|string|true|none|
|body|body|object|false|none|
|» content|body|string|false|none|
|» attachments|body|[[Attachment](#schemaattachment)]|false|none|
|»» Attachment|body|[Attachment](#schemaattachment)|false|none|
|»»» url|body|string|false|none|
|»»» filename|body|string|false|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "message": {
    "_id": "string",
    "convoID": "string",
    "userID": "string",
    "content": "string",
    "created_at": 0,
    "attachments": [
      {
        "url": "string",
        "filename": "string"
      }
    ],
    "is_active": true,
    "is_unread": true
  }
}
```

<h3 id="create-a-new-message-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Returns the new message|Inline|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You do not have access rights to this conversation.|[APIError](#schemaapierror)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Conversation ID wasnt found|[APIError](#schemaapierror)|

<h3 id="create-a-new-message-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» message|[ChatMessage](#schemachatmessage)|false|none|none|
|»» _id|string|false|none|none|
|»» convoID|string|false|none|none|
|»» userID|string|false|none|none|
|»» content|string|false|none|none|
|»» created_at|number|false|none|none|
|»» attachments|[[Attachment](#schemaattachment)]|false|none|none|
|»»» Attachment|[Attachment](#schemaattachment)|false|none|none|
|»»»» url|string|false|none|none|
|»»»» filename|string|false|none|none|
|»» is_active|boolean|false|none|none|
|»» is_unread|boolean|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Remove a user from the conversation

<a id="opIdchat.remove_user"></a>

> Code samples

```python
import requests
headers = {
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/chat/{convoID}/members/{userID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/chat/{convoID}/members/{userID}
</p>

**This will not work as there is a max limit of users in a convo set to 2. If you want to close a DM for good then you must block the other user.**

<h3 id="remove-a-user-from-the-conversation-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|convoID|path|string|true|none|
|userID|path|string|true|none|

<h3 id="remove-a-user-from-the-conversation-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|501|[Not Implemented](https://tools.ietf.org/html/rfc7231#section-6.6.2)|Not Implemented|None|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Delete a message

<a id="opIdchat.delete_message"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/chat/{convoID}/messages/{messageID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/chat/{convoID}/messages/{messageID}
</p>

Requires chat.manage_messages.write

<h3 id="delete-a-message-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|convoID|path|string|true|none|
|messageID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="delete-a-message-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Deleted the message|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|Forbidden|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Edit a message

<a id="opIdchat.edit_message"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/chat/{convoID}/messages/{messageID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/chat/{convoID}/messages/{messageID}
</p>

Requires chat.manage_messages.write

> Body parameter

```json
{
  "content": "string",
  "attachments": {
    "url": "string",
    "filename": "string"
  }
}
```

<h3 id="edit-a-message-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|convoID|path|string|true|none|
|messageID|path|string|true|none|
|body|body|object|false|Only provide the fields you wish to update. You must, however, provide at least 1 field or it wont accept your request.|
|» content|body|string|false|none|
|» attachments|body|[Attachment](#schemaattachment)|false|none|
|»» url|body|string|false|none|
|»» filename|body|string|false|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="edit-a-message-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Updated the message|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|There was an error while validating your input, please make sure that it is valid!|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You dont have access rights to this message/convo|[APIError](#schemaapierror)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Conversation not found|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Mark messages as reasd

<a id="opIdchat.manage_messages.post1"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/chat/{convoID}/ack', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/chat/{convoID}/ack
</p>

Marks the messages as being read.

> Body parameter

```json
{
  "messages": [
    "string"
  ]
}
```

<h3 id="mark-messages-as-reasd-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|convoID|path|string|true|none|
|body|body|object|false|none|
|» messages|body|[string]|false|An array of messageIDs|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="mark-messages-as-reasd-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|One of the message IDs doesnt exist|Inline|

<h3 id="mark-messages-as-reasd-responseschema">Response Schema</h3>

Status Code **404**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» error|string|false|none|none|
|» code|string|false|none|none|
|» index|number|false|none|Index of the message ID that doesnt exist|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Get all conversations unread count

<a id="opIdchat.get_unread"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/chat/@me/unread', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/chat/@me/unread
</p>

Get unread count from all conversations

> Example responses

> 200 Response

```json
{
  "success": "string",
  "unread": {}
}
```

<h3 id="get-all-conversations-unread-count-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="get-all-conversations-unread-count-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» unread|object|false|none|OpenAPI doesnt allow for objects with dynamic keys. The keys in the object are "convoID:Unread count"|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Get block list

<a id="opIdchat.block_list"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/chat/@me/block_list', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/chat/@me/block_list
</p>

Requires chat.manage_blocklist.read

> Example responses

```json
{
  "success": true,
  "block_list": [
    {
      "_id": "1830113509669736448",
      "userID": "1729788214794915840",
      "targetID": "1818881790329360384",
      "created_at": 1579307276,
      "reason": "Was mean",
      "target": {
        "description": "",
        "about": "Whoa! A profile",
        "tags": [],
        "is_nsfw": false,
        "status": "public",
        "theme": "#0a62ac",
        "cards": [],
        "nickname": null,
        "username": "Username!",
        "_id": "1818881790329360384"
      }
    }
  ]
}
```

> 400 Response

```json
{
  "success": true,
  "error": "string",
  "code": "string"
}
```

<h3 id="get-block-list-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<h3 id="get-block-list-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» block_list|[object]|false|none|none|
|»» _id|string|false|none|none|
|»» userID|string|false|none|none|
|»» targetID|string|false|none|none|
|»» created_at|string|false|none|none|
|»» reason|string|false|none|none|
|»» target|[Profile](#schemaprofile)|false|none|A profile object used to describe a creator.|
|»»» _id|string|false|none|none|
|»»» about|string|false|none|none|
|»»» status|string|false|none|none|
|»»» theme|string|false|none|none|
|»»» tags|[string]|false|none|none|
|»»» is_nsfw|string|false|none|none|
|»»» cards|[object]|false|none|none|
|»»» nickname|string|false|none|none|
|»»» username|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Block a user

<a id="opIdchat.block_user"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/chat/@me/block_list', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/chat/@me/block_list
</p>

Requires chat.manage_blocklist.write

> Body parameter

```json
{
  "users": [
    null
  ],
  "reason": "string"
}
```

<h3 id="block-a-user-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|none|
|» users|body|[any]|true|Array of userIDs to block|
|» reason|body|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="block-a-user-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Blocked the users mentioned in the array|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Y'all didnt read the request body did you|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Unblock a user

<a id="opIdchat.unblock_user"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/chat/@me/block_list/{targetID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/chat/@me/block_list/{targetID}
</p>

<h3 id="unblock-a-user-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|targetID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="unblock-a-user-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Unblocked the user|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|The user wasnt blocked before|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

<h1 id="sponsus-api-comments">comments</h1>

## Get a comment's replies

<a id="opIdcomments.get_replies"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/comments/{postID}/comment/{commentID}/replies', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/comments/{postID}/comment/{commentID}/replies
</p>

<h3 id="get-a-comment's-replies-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|
|commentID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "comments": {
    "_id": "string",
    "message": "string",
    "userID": "string",
    "postID": "string",
    "created_at": 0,
    "is_reply": true,
    "user": {
      "_id": "string",
      "username": "string"
    },
    "can_manage": true,
    "can_edit": true,
    "is_creator": true,
    "is_staff": true
  }
}
```

<h3 id="get-a-comment's-replies-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="get-a-comment's-replies-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» comments|[Comment](#schemacomment)|false|none|none|
|»» _id|string|false|none|The id of the comment|
|»» message|string|false|none|none|
|»» userID|string|false|none|none|
|»» postID|string|false|none|none|
|»» created_at|number|false|none|none|
|»» is_reply|boolean|false|none|none|
|»» user|[BasicUser](#schemabasicuser)|false|none|This is a shortform User object|
|»»» _id|string|false|none|none|
|»»» username|string|false|none|none|
|»» can_manage|boolean|false|none|none|
|»» can_edit|boolean|false|none|none|
|»» is_creator|boolean|false|none|none|
|»» is_staff|boolean|false|none|none|

<aside class="success">
This operation does not require authentication
</aside>

## Reply to a comment

<a id="opIdcomments.create_reply"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/comments/{postID}/comment/{commentID}/replies', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/comments/{postID}/comment/{commentID}/replies
</p>

Requires comments.manage_comments.write

> Body parameter

```json
{
  "message": "string"
}
```

<h3 id="reply-to-a-comment-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|
|commentID|path|string|true|none|
|body|body|object|false|none|
|» message|body|string|false|none|

> Example responses

> 201 Response

```json
{
  "success": true
}
```

<h3 id="reply-to-a-comment-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Created the reply|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Get a comment's replies statistics

<a id="opIdcomments.get_comment_reply_stats"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json'
}

r = requests.get('https://api.sponsus.org/v1/comments/{postID}/comment/{commentID}/replies/stats', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/comments/{postID}/comment/{commentID}/replies/stats
</p>

<h3 id="get-a-comment's-replies-statistics-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|
|commentID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true,
  "total": 0
}
```

<h3 id="get-a-comment's-replies-statistics-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|The post was not found|[APIError](#schemaapierror)|

<h3 id="get-a-comment's-replies-statistics-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» total|number|false|none|Total replies to this comment|

<aside class="success">
This operation does not require authentication
</aside>

## List a post's comments

<a id="opIdposts.list_comments"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/comments/{postID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/comments/{postID}
</p>

Requires comments.manage_comments.read

<h3 id="list-a-post's-comments-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": "string",
  "comments": [
    {
      "_id": "string",
      "message": "string",
      "userID": "string",
      "postID": "string",
      "created_at": 0,
      "is_reply": true,
      "user": {
        "_id": "string",
        "username": "string"
      },
      "can_manage": true,
      "can_edit": true,
      "is_creator": true,
      "is_staff": true
    }
  ]
}
```

<h3 id="list-a-post's-comments-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Post was not found|[APIError](#schemaapierror)|

<h3 id="list-a-post's-comments-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» comments|[[Comment](#schemacomment)]|false|none|none|
|»» Comment|[Comment](#schemacomment)|false|none|none|
|»»» _id|string|false|none|The id of the comment|
|»»» message|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» postID|string|false|none|none|
|»»» created_at|number|false|none|none|
|»»» is_reply|boolean|false|none|none|
|»»» user|[BasicUser](#schemabasicuser)|false|none|This is a shortform User object|
|»»»» _id|string|false|none|none|
|»»»» username|string|false|none|none|
|»»» can_manage|boolean|false|none|none|
|»»» can_edit|boolean|false|none|none|
|»»» is_creator|boolean|false|none|none|
|»»» is_staff|boolean|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Create a comment

<a id="opIdposts.create_comment"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/comments/{postID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/comments/{postID}
</p>

Requires comments.manage_comments.write

> Body parameter

```json
{
  "message": "string"
}
```

<h3 id="create-a-comment-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|
|body|body|object|false|none|
|» message|body|string|false|none|

> Example responses

> 201 Response

```json
{
  "success": true
}
```

<h3 id="create-a-comment-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Created|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Delete a comment

<a id="opIdcomments.manage_comment.delete"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/comments/{postID}/comment/{commentID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/comments/{postID}/comment/{commentID}
</p>

Requires comments.manage_comments.write

<h3 id="delete-a-comment-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|
|commentID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="delete-a-comment-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Deleted the comment|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You dont have rights to edit this comment|[APIError](#schemaapierror)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Not Found|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Edit a comment

<a id="opIdcomments.manage_comment.post"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/comments/{postID}/comment/{commentID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/comments/{postID}/comment/{commentID}
</p>

Requires comments.manage_comments.write

> Body parameter

```json
{
  "message": "string"
}
```

<h3 id="edit-a-comment-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|postID|path|string|true|none|
|commentID|path|string|true|none|
|body|body|object|false|none|
|» message|body|string|false|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="edit-a-comment-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Updated the comment|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You dont have rights to edit this comment|[APIError](#schemaapierror)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Not Found|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

<h1 id="sponsus-api-authentication">authentication</h1>

## Update your account

<a id="opIdauthentication.manage_user_account"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
}

r = requests.post('https://api.sponsus.org/v1/auth/@me', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/auth/@me
</p>

Update user account

> Body parameter

```json
{
  "username": "string",
  "view_nsfw": true
}
```

<h3 id="update-your-account-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|[updates](#schemaupdates)|false|Your username|

> Example responses

> 200 Response

```json
{}
```

> 400 Response

```json
{
  "success": true,
  "error": "string",
  "code": "string"
}
```

<h3 id="update-your-account-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[APIError](#schemaapierror)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|Forbidden|[APIError](#schemaapierror)|

<aside class="success">
This operation does not require authentication
</aside>

<h1 id="sponsus-api-teams">teams</h1>

## Get my teams

<a id="opIdteams.list_teams"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/permissions/@me/teams', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/permissions/@me/teams
</p>

Requires teams.teams.read

> Example responses

> 200 Response

```json
{
  "success": true,
  "teams": [
    {
      "_id": "string",
      "userID": "string",
      "creatorID": "string",
      "roleID": "string",
      "created_at": "string",
      "status": "string",
      "role": {
        "_id": "string",
        "title": "string",
        "description": "string",
        "permissions": [
          "string"
        ],
        "url_overrides": "string",
        "color": "string",
        "userID": "string",
        "created_at": "string",
        "position": "string"
      },
      "creator": {
        "_id": "string",
        "username": "string"
      }
    }
  ]
}
```

<h3 id="get-my-teams-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="get-my-teams-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» teams|[[TeamMember](#schemateammember)]|false|none|none|
|»» TeamMember|[TeamMember](#schemateammember)|false|none|none|
|»»» _id|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» creatorID|string|false|none|none|
|»»» roleID|string|false|none|none|
|»»» created_at|string|false|none|none|
|»»» status|string|false|none|none|
|»»» role|[TeamRole](#schemateamrole)|false|none|none|
|»»»» _id|string|false|none|none|
|»»»» title|string|false|none|none|
|»»»» description|string|false|none|none|
|»»»» permissions|[string]|false|none|An array of active permissions|
|»»»» url_overrides|string|false|none|none|
|»»»» color|string|false|none|none|
|»»»» userID|string|false|none|none|
|»»»» created_at|string|false|none|none|
|»»»» position|string|false|none|none|
|»»» creator|[BasicUser](#schemabasicuser)|false|none|This is a shortform User object|
|»»»» _id|string|false|none|none|
|»»»» username|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Leave a team/Remove a user from a team

<a id="opIdteams.remove_member"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/permissions/{creatorID}/team/{userID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/permissions/{creatorID}/team/{userID}
</p>

Requires teams.teams.write

<h3 id="leave-a-team/remove-a-user-from-a-team-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|creatorID|path|string|true|none|
|userID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="leave-a-team/remove-a-user-from-a-team-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You do not have rights to edit this team|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Edit a team member

<a id="opIdteams.edit_member"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/permissions/{creatorID}/team/{userID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/permissions/{creatorID}/team/{userID}
</p>

Requires teams.teams.write

Update a members roles

> Body parameter

```json
{
  "roleID": "string"
}
```

<h3 id="edit-a-team-member-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|creatorID|path|string|true|none|
|userID|path|string|true|none|
|body|body|object|false|none|
|» roleID|body|string|false|The roleID you want to set their permissions to|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="edit-a-team-member-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|The user is not apart of the team.|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|The roleID you provided doesnt exist|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Accept a team invite

<a id="opIdteam.accept_invite"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/permissions/{creatorID}/team/accept_invite', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/permissions/{creatorID}/team/accept_invite
</p>

Requires teams.teams.write

<h3 id="accept-a-team-invite-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|creatorID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="accept-a-team-invite-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|You have already accepted the invite|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You are not invited to this team|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Invite a user to your team

<a id="opIdteams.invite"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/permissions/@me/team/{userID}/invite', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/permissions/@me/team/{userID}/invite
</p>

Requires teams.teams.write

> Body parameter

```json
{}
```

<h3 id="invite-a-user-to-your-team-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|userID|path|string|true|none|
|body|body|object|false|Body will be ignored|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="invite-a-user-to-your-team-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Invited the user to your team, please wait for them to accept the invite!|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|User has already been invited|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|The user was not found|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Search for new team members

<a id="opIdteams.search"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/permissions/@me/team/search', params={
  'q': 'string'
}, headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/permissions/@me/team/search
</p>

Requires teams.teams.read

<h3 id="search-for-new-team-members-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|q|query|string|true|The username to search for|

> Example responses

> 200 Response

```json
{
  "success": "string",
  "users": [
    {
      "_id": "string",
      "username": "string",
      "status": "string"
    }
  ]
}
```

<h3 id="search-for-new-team-members-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Returns users that can be invited or have been invited already. Check the status field before attempting to invite|Inline|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Something is wrong with the query param. You either didnt set it, or set it too long.|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<h3 id="search-for-new-team-members-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» users|[object]|false|none|none|
|»» _id|string|false|none|the users ID|
|»» username|string|false|none|The username|
|»» status|string|false|none|The status of the user, if they have been invited this will be set to "Pending" otherwise it is "Avalible"|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Delete a role

<a id="opIdteams.delete_role"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.delete('https://api.sponsus.org/v1/permissions/@me/roles/{roleID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">DELETE</span>
    /v1/permissions/@me/roles/{roleID}
</p>

<h3 id="delete-a-role-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|roleID|path|string|true|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="delete-a-role-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Deleted the role|[APIBasicSuccess](#schemaapibasicsuccess)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You dont have rights to edit this role|[APIError](#schemaapierror)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Role not found|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## Update a team role

<a id="opIdteams.edit_role"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.post('https://api.sponsus.org/v1/permissions/@me/roles/{roleID}', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/permissions/@me/roles/{roleID}
</p>

Requires teams.roles.write

> Body parameter

```json
{
  "permissions": [
    "string"
  ],
  "color": "string",
  "title": "string",
  "description": "string"
}
```

<h3 id="update-a-team-role-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|roleID|path|string|true|none|
|body|body|object|false|none|
|» permissions|body|[string]|false|none|
|» color|body|string|false|none|
|» title|body|string|false|none|
|» description|body|string|false|none|

> Example responses

> 200 Response

```json
{
  "success": true
}
```

<h3 id="update-a-team-role-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Updated this role|[APIBasicSuccess](#schemaapibasicsuccess)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Input validation error|[APIError](#schemaapierror)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|You dont have rights to edit this role|[APIError](#schemaapierror)|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## List my team's roles

<a id="opIdteams.list_roles"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/permissions/@me/roles', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/permissions/@me/roles
</p>

Requires teams.roles.read

> Example responses

> 200 Response

```json
{
  "success": true,
  "roles": [
    {
      "_id": "string",
      "title": "string",
      "description": "string",
      "permissions": [
        "string"
      ],
      "url_overrides": "string",
      "color": "string",
      "userID": "string",
      "created_at": "string",
      "position": "string"
    }
  ]
}
```

<h3 id="list-my-team's-roles-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<h3 id="list-my-team's-roles-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|boolean|false|none|none|
|» roles|[[TeamRole](#schemateamrole)]|false|none|none|
|»» TeamRole|[TeamRole](#schemateamrole)|false|none|none|
|»»» _id|string|false|none|none|
|»»» title|string|false|none|none|
|»»» description|string|false|none|none|
|»»» permissions|[string]|false|none|An array of active permissions|
|»»» url_overrides|string|false|none|none|
|»»» color|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» created_at|string|false|none|none|
|»»» position|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

<h1 id="sponsus-api-perm">perm</h1>

## Get my team

<a id="opIdteams.team"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'API_KEY'
}

r = requests.get('https://api.sponsus.org/v1/permissions/@me/team', headers = headers)

print(r.json())

```

<p class="path-string">
    <span class="method-tag">GET</span>
    /v1/permissions/@me/team
</p>

Requires teams.teams.read

> Example responses

> 200 Response

```json
{
  "success": "string",
  "members": [
    {
      "_id": "string",
      "userID": "string",
      "creatorID": "string",
      "roleID": "string",
      "created_at": "string",
      "status": "string",
      "role": {
        "_id": "string",
        "title": "string",
        "description": "string",
        "permissions": [
          "string"
        ],
        "url_overrides": "string",
        "color": "string",
        "userID": "string",
        "created_at": "string",
        "position": "string"
      },
      "creator": {
        "_id": "string",
        "username": "string"
      }
    }
  ]
}
```

<h3 id="get-my-team-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[APIKeyNoPermissions](#schemaapikeynopermissions)|

<h3 id="get-my-team-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» success|string|false|none|none|
|» members|[[TeamMember](#schemateammember)]|false|none|none|
|»» TeamMember|[TeamMember](#schemateammember)|false|none|none|
|»»» _id|string|false|none|none|
|»»» userID|string|false|none|none|
|»»» creatorID|string|false|none|none|
|»»» roleID|string|false|none|none|
|»»» created_at|string|false|none|none|
|»»» status|string|false|none|none|
|»»» role|[TeamRole](#schemateamrole)|false|none|none|
|»»»» _id|string|false|none|none|
|»»»» title|string|false|none|none|
|»»»» description|string|false|none|none|
|»»»» permissions|[string]|false|none|An array of active permissions|
|»»»» url_overrides|string|false|none|none|
|»»»» color|string|false|none|none|
|»»»» userID|string|false|none|none|
|»»»» created_at|string|false|none|none|
|»»»» position|string|false|none|none|
|»»» creator|[BasicUser](#schemabasicuser)|false|none|This is a shortform User object|
|»»»» _id|string|false|none|none|
|»»»» username|string|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
ApiKeyAuth
</aside>

## perm.manage_creator_roles.post

<a id="opIdperm.manage_creator_roles.post"></a>

> Code samples

```python
import requests

r = requests.post('https://api.sponsus.org/v1/permissions/@me/roles')

print(r.json())

```

<p class="path-string">
    <span class="method-tag">POST</span>
    /v1/permissions/@me/roles
</p>

<h3 id="perm.manage_creator_roles.post-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|None|

<aside class="success">
This operation does not require authentication
</aside>

# Schemas

<h2 id="tocS_Profile">Profile</h2>
<!-- backwards compatibility -->
<a id="schemaprofile"></a>
<a id="schema_Profile"></a>
<a id="tocSprofile"></a>
<a id="tocsprofile"></a>

```json
{
  "_id": "string",
  "about": "string",
  "status": "string",
  "theme": "string",
  "tags": [
    "string"
  ],
  "is_nsfw": "string",
  "cards": [
    {}
  ],
  "nickname": "string",
  "username": "string"
}

```

Profile

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|about|string|false|none|none|
|status|string|false|none|none|
|theme|string|false|none|none|
|tags|[string]|false|none|none|
|is_nsfw|string|false|none|none|
|cards|[object]|false|none|none|
|nickname|string|false|none|none|
|username|string|false|none|none|

<h2 id="tocS_ProfileCard">ProfileCard</h2>
<!-- backwards compatibility -->
<a id="schemaprofilecard"></a>
<a id="schema_ProfileCard"></a>
<a id="tocSprofilecard"></a>
<a id="tocsprofilecard"></a>

```json
{
  "title": "string",
  "content": "string",
  "image": "string",
  "link": "string"
}

```

ProfileCard

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|title|string|false|none|none|
|content|string|false|none|none|
|image|string|false|none|none|
|link|string|false|none|none|

<h2 id="tocS_APIError">APIError</h2>
<!-- backwards compatibility -->
<a id="schemaapierror"></a>
<a id="schema_APIError"></a>
<a id="tocSapierror"></a>
<a id="tocsapierror"></a>

```json
{
  "success": true,
  "error": "string",
  "code": "string"
}

```

APIError

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|boolean|false|none|none|
|error|string|false|none|none|
|code|string|false|none|none|

<h2 id="tocS_APIBasicSuccess">APIBasicSuccess</h2>
<!-- backwards compatibility -->
<a id="schemaapibasicsuccess"></a>
<a id="schema_APIBasicSuccess"></a>
<a id="tocSapibasicsuccess"></a>
<a id="tocsapibasicsuccess"></a>

```json
{
  "success": true
}

```

APIBasicSuccess

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|boolean|false|none|none|

<h2 id="tocS_Tier">Tier</h2>
<!-- backwards compatibility -->
<a id="schematier"></a>
<a id="schema_Tier"></a>
<a id="tocStier"></a>
<a id="tocstier"></a>

```json
{
  "_id": "string",
  "title": "string",
  "price": 0,
  "description": "string",
  "userID": "string",
  "advanced": {},
  "created_at": 0,
  "support": {
    "is_supporting": true
  }
}

```

Tier

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|true|none|none|
|title|string|true|none|none|
|price|number|true|none|none|
|description|string|true|none|none|
|userID|string|true|none|none|
|advanced|object|false|none|none|
|created_at|number|false|none|none|
|support|[Support](#schemasupport)|false|none|none|

<h2 id="tocS_APIKeyNoPermissions">APIKeyNoPermissions</h2>
<!-- backwards compatibility -->
<a id="schemaapikeynopermissions"></a>
<a id="schema_APIKeyNoPermissions"></a>
<a id="tocSapikeynopermissions"></a>
<a id="tocsapikeynopermissions"></a>

```json
{
  "success": "string",
  "error": "string",
  "code": "string",
  "missing_permission": "string"
}

```

APIKeyNoPermissions

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|none|
|error|string|false|none|none|
|code|string|false|none|none|
|missing_permission|string|false|none|none|

<h2 id="tocS_Sponsorship">Sponsorship</h2>
<!-- backwards compatibility -->
<a id="schemasponsorship"></a>
<a id="schema_Sponsorship"></a>
<a id="tocSsponsorship"></a>
<a id="tocssponsorship"></a>

```json
{
  "tier": {
    "_id": "string",
    "title": "string",
    "price": 0,
    "description": "string",
    "userID": "string",
    "advanced": {},
    "created_at": 0,
    "support": {
      "is_supporting": true
    }
  },
  "price": 0,
  "owner": {
    "_id": "string",
    "about": "string",
    "status": "string",
    "theme": "string",
    "tags": [
      "string"
    ],
    "is_nsfw": "string",
    "cards": [
      {}
    ],
    "nickname": "string",
    "username": "string"
  },
  "is_active": true,
  "is_custom": true,
  "charge_amount": 0
}

```

Sponsorship

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|tier|[Tier](#schematier)|false|none|A tier for a creator.|
|price|number|false|none|none|
|owner|[Profile](#schemaprofile)|false|none|A profile object used to describe a creator.|
|is_active|boolean|false|none|none|
|is_custom|boolean|false|none|none|
|charge_amount|number|false|none|none|

<h2 id="tocS_IncomingSponsorship">IncomingSponsorship</h2>
<!-- backwards compatibility -->
<a id="schemaincomingsponsorship"></a>
<a id="schema_IncomingSponsorship"></a>
<a id="tocSincomingsponsorship"></a>
<a id="tocsincomingsponsorship"></a>

```json
{
  "userID": "string",
  "created_at": 0,
  "is_active": true,
  "targetID": "string",
  "tier": {
    "_id": "string",
    "title": "string",
    "price": 0,
    "description": "string",
    "userID": "string",
    "advanced": {},
    "created_at": 0,
    "support": {
      "is_supporting": true
    }
  },
  "has_paid": true,
  "current_month": "string",
  "is_custom": true,
  "active_total": 0,
  "active_sponsorship_total": 0
}

```

IncomingSponsorship

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|userID|string|true|none|none|
|created_at|number|true|none|none|
|is_active|boolean|true|none|none|
|targetID|string|true|none|none|
|tier|[Tier](#schematier)|false|none|A tier for a creator.|
|has_paid|boolean|true|none|none|
|current_month|string|true|none|none|
|is_custom|boolean|false|none|none|
|active_total|number|false|none|none|
|active_sponsorship_total|number|false|none|none|

<h2 id="tocS_Charge">Charge</h2>
<!-- backwards compatibility -->
<a id="schemacharge"></a>
<a id="schema_Charge"></a>
<a id="tocScharge"></a>
<a id="tocscharge"></a>

```json
{
  "_id": "string",
  "amount": "string",
  "destination": {
    "_id": "string",
    "username": "string"
  },
  "created_at": "string",
  "avalible_at": "string",
  "user": {
    "_id": "string",
    "username": "string"
  },
  "type": "string",
  "avalible_percent": "string",
  "created_at_stamp": "string"
}

```

Charge

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|true|none|none|
|amount|string|true|none|none|
|destination|[BasicUser](#schemabasicuser)|false|none|This is a shortform User object|
|created_at|string|true|none|none|
|avalible_at|string|true|none|none|
|user|[BasicUser](#schemabasicuser)|false|none|This is a shortform User object|
|type|string|false|none|none|
|avalible_percent|string|false|none|none|
|created_at_stamp|string|false|none|none|

<h2 id="tocS_BasicUser">BasicUser</h2>
<!-- backwards compatibility -->
<a id="schemabasicuser"></a>
<a id="schema_BasicUser"></a>
<a id="tocSbasicuser"></a>
<a id="tocsbasicuser"></a>

```json
{
  "_id": "string",
  "username": "string"
}

```

BasicUser

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|username|string|false|none|none|

<h2 id="tocS_payments.get_chargesResponse">payments.get_chargesResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.get_chargesresponse"></a>
<a id="schema_payments.get_chargesResponse"></a>
<a id="tocSpayments.get_chargesresponse"></a>
<a id="tocspayments.get_chargesresponse"></a>

```json
{
  "success": "string",
  "charges": [
    {
      "_id": "string",
      "amount": "string",
      "destination": {
        "_id": "string",
        "username": "string"
      },
      "created_at": "string",
      "avalible_at": "string",
      "user": {
        "_id": "string",
        "username": "string"
      },
      "type": "string",
      "avalible_percent": "string",
      "created_at_stamp": "string"
    }
  ]
}

```

payments.get_chargesResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|none|
|charges|[[Charge](#schemacharge)]|false|none|none|

<h2 id="tocS_payments.get_tier.getResponse">payments.get_tier.getResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.get_tier.getresponse"></a>
<a id="schema_payments.get_tier.getResponse"></a>
<a id="tocSpayments.get_tier.getresponse"></a>
<a id="tocspayments.get_tier.getresponse"></a>

```json
{
  "success": "string",
  "tier": {
    "_id": "string",
    "title": "string",
    "price": 0,
    "description": "string",
    "userID": "string",
    "advanced": {},
    "created_at": 0,
    "support": {
      "is_supporting": true
    }
  }
}

```

payments.get_tier.getResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|none|
|tier|[Tier](#schematier)|false|none|A tier for a creator.|

<h2 id="tocS_payments.get_tierResponse">payments.get_tierResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.get_tierresponse"></a>
<a id="schema_payments.get_tierResponse"></a>
<a id="tocSpayments.get_tierresponse"></a>
<a id="tocspayments.get_tierresponse"></a>

```json
{
  "success": true,
  "total_left": 0
}

```

payments.get_tierResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|boolean|false|none|none|
|total_left|number|false|none|How many sponsorship slots are left before no more can be added.|

<h2 id="tocS_payments.get_user_sponsoring_statusResponse">payments.get_user_sponsoring_statusResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.get_user_sponsoring_statusresponse"></a>
<a id="schema_payments.get_user_sponsoring_statusResponse"></a>
<a id="tocSpayments.get_user_sponsoring_statusresponse"></a>
<a id="tocspayments.get_user_sponsoring_statusresponse"></a>

```json
{
  "success": true,
  "sponsorship": {
    "userID": "string",
    "created_at": 0,
    "is_active": true,
    "targetID": "string",
    "tier": {
      "_id": "string",
      "title": "string",
      "price": 0,
      "description": "string",
      "userID": "string",
      "advanced": {},
      "created_at": 0,
      "support": {
        "is_supporting": true
      }
    },
    "has_paid": true,
    "current_month": "string",
    "is_custom": true,
    "active_total": 0,
    "active_sponsorship_total": 0
  }
}

```

payments.get_user_sponsoring_statusResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|boolean|false|none|none|
|sponsorship|[IncomingSponsorship](#schemaincomingsponsorship)|false|none|Slightly different to the standard sponsorship object. Needs more information and doesnt need to provide creator context (since the person calling the route is the creator)|

<h2 id="tocS_payments.get_user_supportingResponse">payments.get_user_supportingResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.get_user_supportingresponse"></a>
<a id="schema_payments.get_user_supportingResponse"></a>
<a id="tocSpayments.get_user_supportingresponse"></a>
<a id="tocspayments.get_user_supportingresponse"></a>

```json
{
  "success": "string",
  "supporting": [
    {
      "tier": {
        "_id": "string",
        "title": "string",
        "price": 0,
        "description": "string",
        "userID": "string",
        "advanced": {},
        "created_at": 0,
        "support": {
          "is_supporting": true
        }
      },
      "price": 0,
      "owner": {
        "_id": "string",
        "about": "string",
        "status": "string",
        "theme": "string",
        "tags": [
          "string"
        ],
        "is_nsfw": "string",
        "cards": [
          {}
        ],
        "nickname": "string",
        "username": "string"
      },
      "is_active": true,
      "is_custom": true,
      "charge_amount": 0
    }
  ]
}

```

payments.get_user_supportingResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|none|
|supporting|[[Sponsorship](#schemasponsorship)]|false|none|none|

<h2 id="tocS_payments.get_user_tiersResponse">payments.get_user_tiersResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.get_user_tiersresponse"></a>
<a id="schema_payments.get_user_tiersResponse"></a>
<a id="tocSpayments.get_user_tiersresponse"></a>
<a id="tocspayments.get_user_tiersresponse"></a>

```json
{
  "success": "string",
  "tiers": [
    {
      "_id": "string",
      "title": "string",
      "price": 0,
      "description": "string",
      "userID": "string",
      "advanced": {},
      "created_at": 0,
      "support": {
        "is_supporting": true
      }
    }
  ]
}

```

payments.get_user_tiersResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|none|
|tiers|[[Tier](#schematier)]|false|none|[A tier for a creator.]|

<h2 id="tocS_payments.manage_tiers.getResponse">payments.manage_tiers.getResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.manage_tiers.getresponse"></a>
<a id="schema_payments.manage_tiers.getResponse"></a>
<a id="tocSpayments.manage_tiers.getresponse"></a>
<a id="tocspayments.manage_tiers.getresponse"></a>

```json
{
  "success": true,
  "tiers": [
    {
      "_id": "string",
      "title": "string",
      "price": 0,
      "description": "string",
      "userID": "string",
      "advanced": {},
      "created_at": 0,
      "support": {
        "is_supporting": true
      }
    }
  ]
}

```

payments.manage_tiers.getResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|boolean|false|none|none|
|tiers|[[Tier](#schematier)]|false|none|[A tier for a creator.]|

<h2 id="tocS_payments.manage_tiers.postResponse">payments.manage_tiers.postResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.manage_tiers.postresponse"></a>
<a id="schema_payments.manage_tiers.postResponse"></a>
<a id="tocSpayments.manage_tiers.postresponse"></a>
<a id="tocspayments.manage_tiers.postresponse"></a>

```json
{
  "success": true,
  "tier": {
    "_id": "string",
    "title": "string",
    "price": 0,
    "description": "string",
    "userID": "string",
    "advanced": {},
    "created_at": 0,
    "support": {
      "is_supporting": true
    }
  }
}

```

payments.manage_tiers.postResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|boolean|false|none|none|
|tier|[Tier](#schematier)|false|none|A tier for a creator.|

<h2 id="tocS_payments.payment_statsResponse">payments.payment_statsResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.payment_statsresponse"></a>
<a id="schema_payments.payment_statsResponse"></a>
<a id="tocSpayments.payment_statsresponse"></a>
<a id="tocspayments.payment_statsresponse"></a>

```json
{
  "success": "string",
  "total": 0,
  "due": 0,
  "sponsorships": 0,
  "sponsors": 0
}

```

payments.payment_statsResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|Beep!|
|total|number|false|none|Amount given to this user per month from sponsors|
|due|number|false|none|How much this user must pay each month|
|sponsorships|number|false|none|How many creators this user is sponsoring|
|sponsors|number|false|none|How many people are sponsoring this creator|

<h2 id="tocS_payments.set_donation_settingsResponse">payments.set_donation_settingsResponse</h2>
<!-- backwards compatibility -->
<a id="schemapayments.set_donation_settingsresponse"></a>
<a id="schema_payments.set_donation_settingsResponse"></a>
<a id="tocSpayments.set_donation_settingsresponse"></a>
<a id="tocspayments.set_donation_settingsresponse"></a>

```json
{
  "success": true,
  "enabled": true,
  "length": "string",
  "limit": "string",
  "social_media_image": "string"
}

```

payments.set_donation_settingsResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|boolean|false|none|none|
|enabled|boolean|false|none|none|
|length|string|false|none|none|
|limit|string|false|none|none|
|social_media_image|string|false|none|none|

<h2 id="tocS_profile.calc_per_month.getResponse">profile.calc_per_month.getResponse</h2>
<!-- backwards compatibility -->
<a id="schemaprofile.calc_per_month.getresponse"></a>
<a id="schema_profile.calc_per_month.getResponse"></a>
<a id="tocSprofile.calc_per_month.getresponse"></a>
<a id="tocsprofile.calc_per_month.getresponse"></a>

```json
{
  "success": "string",
  "sponsors": 0,
  "total": 0
}

```

profile.calc_per_month.getResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|true|none|none|
|sponsors|number|false|none|How many sponsorships does this creator have|
|total|number|false|none|How much, in $, does this creator get|

<h2 id="tocS_profile.get_post_tagsResponse">profile.get_post_tagsResponse</h2>
<!-- backwards compatibility -->
<a id="schemaprofile.get_post_tagsresponse"></a>
<a id="schema_profile.get_post_tagsResponse"></a>
<a id="tocSprofile.get_post_tagsresponse"></a>
<a id="tocsprofile.get_post_tagsresponse"></a>

```json
{
  "success": "string",
  "tags": [
    [
      "string"
    ]
  ]
}

```

profile.get_post_tagsResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|none|
|tags|[array]|false|none|none|

<h2 id="tocS_profile.get_post_totalResponse">profile.get_post_totalResponse</h2>
<!-- backwards compatibility -->
<a id="schemaprofile.get_post_totalresponse"></a>
<a id="schema_profile.get_post_totalResponse"></a>
<a id="tocSprofile.get_post_totalresponse"></a>
<a id="tocsprofile.get_post_totalresponse"></a>

```json
{
  "success": "string",
  "total": 0
}

```

profile.get_post_totalResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|none|
|total|number|false|none|none|

<h2 id="tocS_profile.get_set_user_profile.getResponse">profile.get_set_user_profile.getResponse</h2>
<!-- backwards compatibility -->
<a id="schemaprofile.get_set_user_profile.getresponse"></a>
<a id="schema_profile.get_set_user_profile.getResponse"></a>
<a id="tocSprofile.get_set_user_profile.getresponse"></a>
<a id="tocsprofile.get_set_user_profile.getresponse"></a>

```json
{
  "success": "string",
  "profile": {
    "_id": "string",
    "about": "string",
    "status": "string",
    "theme": "string",
    "tags": [
      "string"
    ],
    "is_nsfw": "string",
    "cards": [
      {}
    ],
    "nickname": "string",
    "username": "string"
  }
}

```

profile.get_set_user_profile.getResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|none|
|profile|[Profile](#schemaprofile)|false|none|A profile object used to describe a creator.|

<h2 id="tocS_profile.get_user_avatar_infoResponse">profile.get_user_avatar_infoResponse</h2>
<!-- backwards compatibility -->
<a id="schemaprofile.get_user_avatar_inforesponse"></a>
<a id="schema_profile.get_user_avatar_infoResponse"></a>
<a id="tocSprofile.get_user_avatar_inforesponse"></a>
<a id="tocsprofile.get_user_avatar_inforesponse"></a>

```json
{
  "success": true,
  "is_image": "string",
  "key": "string"
}

```

profile.get_user_avatar_infoResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|boolean|false|none|none|
|is_image|string|false|none|none|
|key|string|false|none|none|

<h2 id="tocS_profile.get_user_profileResponse">profile.get_user_profileResponse</h2>
<!-- backwards compatibility -->
<a id="schemaprofile.get_user_profileresponse"></a>
<a id="schema_profile.get_user_profileResponse"></a>
<a id="tocSprofile.get_user_profileresponse"></a>
<a id="tocsprofile.get_user_profileresponse"></a>

```json
{
  "success": "string",
  "profile": {
    "_id": "string",
    "about": "string",
    "status": "string",
    "theme": "string",
    "tags": [
      "string"
    ],
    "is_nsfw": "string",
    "cards": [
      {}
    ],
    "nickname": "string",
    "username": "string"
  }
}

```

profile.get_user_profileResponse

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|success|string|false|none|none|
|profile|[Profile](#schemaprofile)|false|none|A profile object used to describe a creator.|

<h2 id="tocS_Support">Support</h2>
<!-- backwards compatibility -->
<a id="schemasupport"></a>
<a id="schema_Support"></a>
<a id="tocSsupport"></a>
<a id="tocssupport"></a>

```json
{
  "is_supporting": true
}

```

Support

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|is_supporting|boolean|false|none|none|

<h2 id="tocS_updates">updates</h2>
<!-- backwards compatibility -->
<a id="schemaupdates"></a>
<a id="schema_updates"></a>
<a id="tocSupdates"></a>
<a id="tocsupdates"></a>

```json
{
  "username": "string",
  "view_nsfw": true
}

```

updates

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|username|string|false|none|none|
|view_nsfw|boolean|false|none|none|

<h2 id="tocS_Post">Post</h2>
<!-- backwards compatibility -->
<a id="schemapost"></a>
<a id="schema_Post"></a>
<a id="tocSpost"></a>
<a id="tocspost"></a>

```json
{
  "_id": "string",
  "_id_str": "string",
  "title_slug": "string",
  "type": "string",
  "title": "string",
  "price_to_view": 0,
  "authorID_str": "string",
  "authorID": "string",
  "userID_str": "string",
  "userID": "string",
  "created_at": 0,
  "published_at": 0,
  "is_nsfw": true,
  "is_hidden": true,
  "tags": [
    "string"
  ],
  "comment_count": 0,
  "can_edit": true,
  "content": "string",
  "images": [
    "string"
  ],
  "audio": {
    "src": "string",
    "cover_image": "string",
    "background_image": "string",
    "include_in_rss": "string",
    "title": "string"
  },
  "video": "string"
}

```

Post

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|_id_str|string|false|none|none|
|title_slug|string|false|none|none|
|type|string|false|none|none|
|title|string|false|none|none|
|price_to_view|number|false|none|none|
|authorID_str|string|false|none|none|
|authorID|string|false|none|none|
|userID_str|string|false|none|none|
|userID|string|false|none|none|
|created_at|number|false|none|none|
|published_at|number|false|none|none|
|is_nsfw|boolean|false|none|none|
|is_hidden|boolean|false|none|none|
|tags|[string]|false|none|none|
|comment_count|number|false|none|none|
|can_edit|boolean|false|none|none|
|content|string|false|none|none|
|images|[string]|false|none|none|
|audio|object|false|none|none|
|» src|string|false|none|none|
|» cover_image|string|false|none|none|
|» background_image|string|false|none|none|
|» include_in_rss|string|false|none|none|
|» title|string|false|none|none|
|video|string|false|none|none|

<h2 id="tocS_LockedPost">LockedPost</h2>
<!-- backwards compatibility -->
<a id="schemalockedpost"></a>
<a id="schema_LockedPost"></a>
<a id="tocSlockedpost"></a>
<a id="tocslockedpost"></a>

```json
{
  "_id": "string",
  "_id_str": "string",
  "title_slug": "string",
  "type": "string",
  "title": "string",
  "price_to_view": 0,
  "authorID_str": "string",
  "authorID": "string",
  "userID_str": "string",
  "userID": "string",
  "created_at": 0,
  "published_at": 0,
  "is_nsfw": true,
  "is_hidden": true,
  "tags": [
    "string"
  ],
  "comment_count": 0,
  "can_edit": true,
  "locked": 0,
  "payment_error": "string"
}

```

LockedPost

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|_id_str|string|false|none|none|
|title_slug|string|false|none|none|
|type|string|false|none|none|
|title|string|false|none|none|
|price_to_view|number|false|none|none|
|authorID_str|string|false|none|none|
|authorID|string|false|none|none|
|userID_str|string|false|none|none|
|userID|string|false|none|none|
|created_at|number|false|none|none|
|published_at|number|false|none|none|
|is_nsfw|boolean|false|none|none|
|is_hidden|boolean|false|none|none|
|tags|[string]|false|none|none|
|comment_count|number|false|none|none|
|can_edit|boolean|false|none|none|
|locked|number|false|none|none|
|payment_error|string|false|none|none|

<h2 id="tocS_SecretKey">SecretKey</h2>
<!-- backwards compatibility -->
<a id="schemasecretkey"></a>
<a id="schema_SecretKey"></a>
<a id="tocSsecretkey"></a>
<a id="tocssecretkey"></a>

```json
{
  "_id": "string",
  "authorID": "string",
  "name": "string",
  "postID": "string",
  "code": "string",
  "uses": 0,
  "expires_at": 0,
  "created_at": 0,
  "views": 0
}

```

SecretKey

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|authorID|string|false|none|none|
|name|string|false|none|none|
|postID|string|false|none|none|
|code|string|false|none|none|
|uses|number|false|none|none|
|expires_at|number|false|none|none|
|created_at|number|false|none|none|
|views|number|false|none|none|

<h2 id="tocS_File">File</h2>
<!-- backwards compatibility -->
<a id="schemafile"></a>
<a id="schema_File"></a>
<a id="tocSfile"></a>
<a id="tocsfile"></a>

```json
{
  "_id": "string",
  "userID": "string",
  "key": "string",
  "hash": "string",
  "filename": "string",
  "filesize": 0,
  "filesize_human": "string",
  "created_at": "string"
}

```

File

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|userID|string|false|none|none|
|key|string|false|none|none|
|hash|string|false|none|none|
|filename|string|false|none|none|
|filesize|number|false|none|none|
|filesize_human|string|false|none|none|
|created_at|string|false|none|none|

<h2 id="tocS_Conversation">Conversation</h2>
<!-- backwards compatibility -->
<a id="schemaconversation"></a>
<a id="schema_Conversation"></a>
<a id="tocSconversation"></a>
<a id="tocsconversation"></a>

```json
{
  "_id": "string",
  "users": "string",
  "created_at": "string",
  "userID": [
    0
  ],
  "is_direct_message": true,
  "title": "string",
  "image": "string",
  "is_active": true
}

```

Conversation

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|users|string|false|none|none|
|created_at|string|false|none|none|
|userID|[number]|false|none|Array of userIDs in the conversation|
|is_direct_message|boolean|false|none|none|
|title|string|false|none|none|
|image|string|false|none|none|
|is_active|boolean|false|none|none|

<h2 id="tocS_Attachment">Attachment</h2>
<!-- backwards compatibility -->
<a id="schemaattachment"></a>
<a id="schema_Attachment"></a>
<a id="tocSattachment"></a>
<a id="tocsattachment"></a>

```json
{
  "url": "string",
  "filename": "string"
}

```

Attachment

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|url|string|false|none|none|
|filename|string|false|none|none|

<h2 id="tocS_ChatMessage">ChatMessage</h2>
<!-- backwards compatibility -->
<a id="schemachatmessage"></a>
<a id="schema_ChatMessage"></a>
<a id="tocSchatmessage"></a>
<a id="tocschatmessage"></a>

```json
{
  "_id": "string",
  "convoID": "string",
  "userID": "string",
  "content": "string",
  "created_at": 0,
  "attachments": [
    {
      "url": "string",
      "filename": "string"
    }
  ],
  "is_active": true,
  "is_unread": true
}

```

ChatMessage

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|convoID|string|false|none|none|
|userID|string|false|none|none|
|content|string|false|none|none|
|created_at|number|false|none|none|
|attachments|[[Attachment](#schemaattachment)]|false|none|none|
|is_active|boolean|false|none|none|
|is_unread|boolean|false|none|none|

<h2 id="tocS_TeamMember">TeamMember</h2>
<!-- backwards compatibility -->
<a id="schemateammember"></a>
<a id="schema_TeamMember"></a>
<a id="tocSteammember"></a>
<a id="tocsteammember"></a>

```json
{
  "_id": "string",
  "userID": "string",
  "creatorID": "string",
  "roleID": "string",
  "created_at": "string",
  "status": "string",
  "role": {
    "_id": "string",
    "title": "string",
    "description": "string",
    "permissions": [
      "string"
    ],
    "url_overrides": "string",
    "color": "string",
    "userID": "string",
    "created_at": "string",
    "position": "string"
  },
  "creator": {
    "_id": "string",
    "username": "string"
  }
}

```

TeamMember

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|userID|string|false|none|none|
|creatorID|string|false|none|none|
|roleID|string|false|none|none|
|created_at|string|false|none|none|
|status|string|false|none|none|
|role|[TeamRole](#schemateamrole)|false|none|none|
|creator|[BasicUser](#schemabasicuser)|false|none|This is a shortform User object|

<h2 id="tocS_TeamRole">TeamRole</h2>
<!-- backwards compatibility -->
<a id="schemateamrole"></a>
<a id="schema_TeamRole"></a>
<a id="tocSteamrole"></a>
<a id="tocsteamrole"></a>

```json
{
  "_id": "string",
  "title": "string",
  "description": "string",
  "permissions": [
    "string"
  ],
  "url_overrides": "string",
  "color": "string",
  "userID": "string",
  "created_at": "string",
  "position": "string"
}

```

TeamRole

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|none|
|title|string|false|none|none|
|description|string|false|none|none|
|permissions|[string]|false|none|An array of active permissions|
|url_overrides|string|false|none|none|
|color|string|false|none|none|
|userID|string|false|none|none|
|created_at|string|false|none|none|
|position|string|false|none|none|

<h2 id="tocS_Comment">Comment</h2>
<!-- backwards compatibility -->
<a id="schemacomment"></a>
<a id="schema_Comment"></a>
<a id="tocScomment"></a>
<a id="tocscomment"></a>

```json
{
  "_id": "string",
  "message": "string",
  "userID": "string",
  "postID": "string",
  "created_at": 0,
  "is_reply": true,
  "user": {
    "_id": "string",
    "username": "string"
  },
  "can_manage": true,
  "can_edit": true,
  "is_creator": true,
  "is_staff": true
}

```

Comment

### Properties

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|_id|string|false|none|The id of the comment|
|message|string|false|none|none|
|userID|string|false|none|none|
|postID|string|false|none|none|
|created_at|number|false|none|none|
|is_reply|boolean|false|none|none|
|user|[BasicUser](#schemabasicuser)|false|none|This is a shortform User object|
|can_manage|boolean|false|none|none|
|can_edit|boolean|false|none|none|
|is_creator|boolean|false|none|none|
|is_staff|boolean|false|none|none|

