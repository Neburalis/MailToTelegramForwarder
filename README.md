# [![Logo](logo/Mail2TelegramForwarder-Bot-small.png)](logo/CREDIT.md) MailToTelegramForwarder - Service
[![Project: MailToTelegramForwarder](https://img.shields.io/badge/Project-MailToTelegramForwarder-red.svg?style=flat-square)](https://github.com/Neburalis/MailToTelegramForwarder/)
[![GitHub issues](https://img.shields.io/github/issues/Neburalis/MailToTelegramForwarder?style=flat-square)](https://github.com/Neburalis/MailToTelegramForwarder/issues) 
![Python version: 3](https://img.shields.io/badge/Version-3-informational?style=flat-square&logo=python)
![API: Telegram Bot](https://img.shields.io/badge/API-Telegram_Bot-informational?style=flat-square&logo=telegram)
[![License: GPL + MIT](https://img.shields.io/badge/license-GPL+MIT-informational?style=flat-square)](README.md#license)
[![GitHub forks](https://img.shields.io/github/forks/Neburalis/MailToTelegramForwarder?style=flat-square)](https://github.com/Neburalis/MailToTelegramForwarder/network) 
[![GitHub stars](https://img.shields.io/github/stars/Neburalis/MailToTelegramForwarder?style=flat-square)](https://github.com/Neburalis/MailToTelegramForwarder/stargazers)

## Description

MailToTelegramForwarder is a Python based daemon that will fetch mails 
from a remote IMAP server and forward them via Telegram API. 
There's no need for a dedicated mail server and piping Alias to a 
script; you can use any IMAP capable provider like gmail, outlook, 
self-hosted, etc. to use this feature. Use of a dedicated IMAP mailbox
is strongly recommended.

The bot only sends messages, it does not respond or listen.

## Installation

### Command line options
`-c`, `--config`: Configuration file. 

`-o`, `--read-old-mails` (optional): Read mails received before application was started.
Can be used to overwrite `read_old_mails` as defined by configuration file.

### Configuration
#### Mail
At least `server`, `user` and `password` have to be updated for access to your
Mail server with IMAP support.

`user`: On many servers email/username should be in format `user@hostname.com`.

`password`:
If you had enabled 2-factor authentication on your mail server (or Google Account),
you have to create an application password for the bot. 
**Hint**: This script does not support 2-factor authentication.
```
[Mail]
# IMAP server
server: <IMAP mail server>
# IMAP port (default: 993)
#port: <IMAP mail server port like 993>

# IMAP user
user: <mailbox user, ex. my-mail-id>
# IMAP password
password: <mailbox password>

# IMAP connection timout in seconds (default: 60)
#timeout: 60

# use timer in seconds
#refresh: 10

# disconnect after each loop, not recommended for short refresh rates: [True|False]
#disconnect: False
```

`folder` [**Default** 'Inbox']: Can be used to restrict forwarded mail to a
predefined folder. Ex.: Mail folder, which contains preprocessed mails by 
server side ruleset(s).  
```
# IMAP folder on server to check, ex.: INBOX (default)
#folder: <IMAP (sub)folder on server>
```

`search` [**Default** '(UID ${lastUID}:* UNSEEN)']: IMAP search command to filter 
mails handled by this script. Predefined default will forward all `UNSEEN` mails 
since script was started. All these mails will be automatically marked as seen.

Check IMAP specs for further information. Most important **search commands**:

`ALL`: All mails

`UID`: Mails UID on server, which can 
defined a range of mails UIDs on mail server. Ex.: `UID <start>:<end>` or `UID <start>:*`. 

`UNSEEN`: Unseen mails, which will be automatically
marked as seen during search.

`HEADER <header field> "<search string>"`:  Search mails by header fields like
**Subject** or **From**. Ex.: `HEADER From "@google.com"` or 
`HEADER Subject "Some News"`

Supported Placeholder for UID value:
`${lastUID}`: Contains UID of most recent mail on startup and will be updated 
to UID of last forwarded mail. Is used to process new mails only (since start
or last loop).

```
# Check IMAP specs for more info.
#search: (UID ${lastUID}:* UNSEEN HEADER Subject "<Subject or Part of Subject>")
```

`read_old_mails` [**Default** False]: Read mails received before application was started.
See command line option `-o` or `--read-old-mails` for one-time use.

`max_length` [**Default** 2000]: Email content will be trimmed, if longer than this
value. HTML messages will be trimmed to this number of characters after unsupported
HTML Elements was removed.

**HINT**: Content will be trimmed after formatting was applied. Hidden HTML or
Markdown elements next to masked characters of Telegram message will be counted too.
Expectation: Forwarded content will be smaller than this value.
```
# max length (characters) of forwarded mail content
#max_length: 2000
```

`ignore_inline_image` Ignore embedded image(s) if regular expression matches source attribute.

**Example**: Remove 1x1 pixel image used for layout based on file name using
`ignore_inline_image: (spacer\.gif)`:
`<img src="http://img.mitarbeiterangebote.de/images/newsletter/spacer.gif"/>`

```
# ignore inline image by regular expression
#ignore_inline_image: (spacer\.gif)
```

#### Telegram
`bot_token`: When the bot is registered via [@botfather](https://telegram.me/botfather)
it will get a unique and long token. Enter this token here (ex.: `123456789:djc28e398e223lkje`).

`forward_to_chat_id`: This script posts messages only to predefined chats, which can 
be a group or individual chat. The easiest way to get the ID of a chat is to add the
[@myidbot](https://telegram.me/myidbot) bot to the chat. After ID bot was started with 
`/start` own ID can be requested by `/getid` (ID >  0), if ID bot was added to a group 
chat `/getgroupid` (ID < 0) provides ID of group chat.

Hint: Bot should be added to the chat to be able to post.
```
[Telegram]
# from @BotFather: Like "<Bot ID:Key>"
bot_token: <Bot Token>
# ID of TG chat or user (<ID>, ex.: 123456) who gets forwarded messages.
forward_to_chat_id: <Chat/User ID>
```

**Optional** part of Telegram related configuration:

`markdown_version`[**Default** 2]: Can be used to switch between version 1 and 2 of
Telegrams markdown, if `prefer_html` was set to `False` or mail has no HTML content.
```
# markdown version: [1|2]
#markdown_version: 2
```

If `prefer_html` [**Default** True] was set to `True`, script prefers HTML content
over plain text part and HTML formatted message will be sent to Telgram:

**Hint**: Can be used to get clickable links from HTML mails in forwarded Telegram
message.
```
# prefer HTML messages: [True|False]
#prefer_html: True
```

If both (`forward_mail_content` and `forward_attachment`) was set to `False` only
a short summary having `From`, `Subject` and names of `attached` file(s) will be
forwarded:

```
# forward attachments: [True|False]
#forward_mail_content: True
# forward attachments: [True|False]
#forward_attachment: True
```

Extract embedded image(s), send them before mail content and add placeholders at original
position with captions of image:

```
# forward embedded images: [True|False]
#forward_embedded_images: True
```

See [configuration template](conf/mailToTelegramForwarder.conf) 
`conf/mailToTelegramForwarder.conf` for further information.

### Running with Docker (recommended)

Docker is the simplest way to run the service — no Python or dependency management required.

#### Build the image
```
docker build -t mail-to-telegram-forwarder .
```

#### Start the container

Edit your configuration file first (see [Configuration](#configuration) above), then mount it into the container:
```
docker run -d \
  --name mail-to-telegram-forwarder \
  --restart unless-stopped \
  -v /path/to/mailToTelegramForwarder.conf:/config/mailToTelegramForwarder.conf:ro \
  mail-to-telegram-forwarder
```

The configuration file is mounted read-only; credentials never become part of the image.

#### View logs
```
docker logs -f mail-to-telegram-forwarder
```

## Update

### Docker
```
docker build -t mail-to-telegram-forwarder .
docker stop mail-to-telegram-forwarder
docker rm mail-to-telegram-forwarder
docker run -d \
  --name mail-to-telegram-forwarder \
  --restart unless-stopped \
  -v /path/to/mailToTelegramForwarder.conf:/config/mailToTelegramForwarder.conf:ro \
  mail-to-telegram-forwarder
```

## Authors

- **Florian Paul Hoberg** - *Initial work* -
  [@gyptazy](https://github.com/gyptazy)
- **angelos-se** - *Fork* - 
  [@angelos-se](https://github.com/angelos-se/IMAPBot) based 
  on - *Initial work* - **Luca Weiss** [@z3ntu](https://github.com/z3ntu/IMAPBot)
  [*Abandoned*]
- **Awalon** - *Merged and enhanced Version* - 
  [@Awalon](https://github.com/awalon/MailToTelegramForwarder)
- **Neburalis** - *Docker support, uv migration and enhancements* -
  [@Neburalis](https://github.com/Neburalis/MailToTelegramForwarder)

## License

This project is licensed under the *GPLv3 License* - see the 
[LICENSE.md](LICENSE.md) file for details, some parts 
(from IMAPBot) are licensed under the *The MIT License (MIT)* - 
see the [LICENSE-MIT.md](LICENSE-MIT.md) file for details.
---
