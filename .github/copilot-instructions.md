# Instructions for Copilot

## User story

User is not professional of the programming and programming related frameworks.
User is researcher and want to improve the research by using the programming and programming related frameworks.
Therefore, user needs you to explain structure of the code, frameworks and libraries in detail and simple terms.

## Code and documentation rules

### General text rules

* Use `,` and `.` instead of `、` and `。` in Japanese
* Don't use `ですます調` in Japanese and use direct speech, lile example below
    * `~する` instead of `~します`
    * `~できる` instead of `~することができます`
    * `~参照` instead of `~参照する`, `~参照します`
    * `~実行` instead of `~実行する`, `~実行します`

### Markdown rules

* Follow the markdown rules (markdownlint)
* Use `*` for lists
* Use `1.` for ordered lists continuously
    * Don't use `2.` after `1.`
* Add line break after all heading
* Add line break before and after lists
* Don't use same heading twice
* Don't add numbers in headings
* Add file type for code blocks
* Add `<` and `>` for URLs
* Add back quotes for file paths
* Use `*` for italic text
* Use `**` for bold text
* Don't use meanless bold text
* Don't use meanless headings
* Add back quotes for code and names
* Use 4 spaces for tab

### Git rules

* Add prefix below for commit message
    * `feat:` for new features
    * `fix:` for bug fixes
    * `refactor:` for code refactoring including formatting and style changes
    * `test:` for adding or modifying tests
    * `docs:` for documentation changes
    * `chore:` for changes to the build process or auxiliary tools and libraries such as documentation generation
