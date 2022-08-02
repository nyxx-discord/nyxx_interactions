## 4.3.1
__01.08.2022__

- bug: Fix global commands selecting guild command handlers

## 4.3.0
__29.07.2022__

- feature: Update to nyxx 4.0.0 (#54)
- feature: Locales (#48)
- feature: Differentiate command handlers per guild

## 4.2.1
__02.05.2022__

- bug: Allow application level permission overrides

## 4.2.0
__29.04.2022__

- feature: Add support for the permissions v2 system
- deprecations: Deprecated all command permission builders, the `defaultPermissions` and `permissions` fields of `SlashCommandBuilder`, the `bulkOverrideGuildCommandsPermissions` endpoint method and `defaultPermissions` from `SlashCommand`.

## 4.1.0
__09.04.2022__

- feature: Add disabled option to `MultiselectBuilder` (#39)
- feature: Add support for minimum and maximum values in CommandOptionBuilder

## 4.0.0
__14.03.2022__

- feature: Implement modals
- feature: Implement attachment option types
- bug: Add missing `messages` field from slash commands resolved data
- bug: Fix guild slash command permissions being overridden even if the sync rule denies sync

## 4.0.0-dev.0.1
__10.2.2022__

- bug: Fix guild slash command permissions being overridden even if the sync rule denies sync

## 4.0.0-dev.0

- feature: Implement modals
- feature: Implement attachment option types
- bug: Add missing `messages` field from slash commands resolved data

## 3.3.0
__13.01.2022__

- feature: Add target_id field to Interaction data (#28)

## 3.2.0
__12.01.2022__

- feature: implement interaction locale (#25)
- bug: fix problem with emojis in buttons (#24)

## 3.1.1
__10.01_2022__

- Fix invalid stream declarations of events in IEventController (#20)
- Fixup example and typos (#16 and #18)

## 3.1.0
__27.12_2021__

- Add missing command option types (#4) @HarryET 

## 3.0.0
__19.12.2021__

- Implemented new interface-based entity model.
  > All concrete implementations of entities are now hidden behind interfaces which exports only behavior which is
  > intended for end developer usage. For example: User is now not exported and its interface `IUser` is available for developers.
  > This change shouldn't have impact of end developers.
- Improved handling autocomplete
  > Autocomplete can be now registered in CommandOptionBuilder. This allows registering multiple autocomplete handler for options
  > with same names.
- Fixed bugs with registering commands and command permissions. This feature should now work flawlessly.
- Fix critical bug preventing commands from being registered
- Fix #10

Other changes are initial implementation of unit and integration tests to assure correct behavior of internal framework
processes. Also added `Makefile` with common commands that are run during development.

## 3.0.0-dev.2
__10.12.2021__

- Fix #10

## 3.0.0-dev.1
__04.12.2021__

- Fix critical bug preventing commands from being registered

## 3.0.0-dev.0
__24.11.2021__

- Implemented new interface-based entity model.
  > All concrete implementations of entities are now hidden behind interfaces which exports only behavior which is
  > intended for end developer usage. For example: User is now not exported and its interface `IUser` is available for developers.
  > This change shouldn't have impact of end developers.
- Improved handling autocomplete
  > Autocomplete can be now registered in CommandOptionBuilder. This allows registering multiple autocomplete handler for options
  > with same names.
- Fixed bugs with registering commands and command permissions. This feature should now work flawlessly.

Other changes are initial implementation of unit and integration tests to assure correct behavior of internal framework
processes. Also added `Makefile` with common commands that are run during development.

## 2.0.3
_03.11.2021_

- allow handlers on different nesting layers, closes nyxx#233 (664fd7cdab23ccbf037e4d29ead92178de7e7660) @abitofevrything

## 2.0.2
_15.10.2021_

- Move to Apache 2 license

## 2.0.1
_03.10.2021_

- fix deserialization of autocomplete interaction

## 2.0.0
_03.10.2021_

> Bumped version to 2.0 for compatibility with nyxx

- Interactions (Slash command) initial implementation (3128388) @HarryET
- Implementation of ephemeral attachments
- Implementation of context menus
- Implementation of message components

---

- Implemented Commander like interface (8fae519)
- Added `subCommand` property to InteractionEvent to ease out recognizing subcommands (5b30b29)


## 2.0.0-rc.4
_21.04.2021_

> **Release Candidate 2 for stable version. Requires dart sdk 2.12**

 - Interactions (Slash command) initial implementation (3128388) @HarryET
 - Implemented Commander like interface (8fae519)
 - Added `subCommand` property to InteractionEvent to ease out recognizing subcommands (5b30b29)

## 1.1-dev.1

 - Initial version @HarryET
