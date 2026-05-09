# MemoryJournal Testing Checklist

This checklist is for quick real-device regression testing before sharing a build or tagging a version.

## Core Journal

- Create a new entry.
- Edit title, date, mood, tags, and Markdown body.
- Cancel an empty draft and confirm it does not remain in the list.
- Save a non-empty entry and confirm it persists after restarting the app.
- Delete an entry from the detail page.
- Delete an entry from the journal list context menu.
- Mark an entry as favorite and confirm it appears in related views.

## Media

- Add one photo.
- Add multiple photos and open the gallery from each tile.
- Swipe between photos in the full-screen gallery.
- Delete a photo attachment.
- Add one video and confirm a thumbnail appears.
- Play a video attachment.
- Delete a video attachment.
- Record audio, stop recording, play it back, and confirm the progress bar moves.
- Delete an audio attachment.

## Location

- Add the current location.
- Search for a location and tap a search result to save it.
- Open a saved location card in Apple Maps.
- Remove the location from an entry.

## Search And Library

- Search by title.
- Search by body text.
- Search by tag.
- Search by mood.
- Search by location.
- Use date range filters.
- Confirm Library cards reflect current entry counts.

## Export And Backup

- Export one entry as PDF.
- Confirm the PDF uses dark text on white background.
- Confirm long body text is not cut off.
- Confirm photos appear in the PDF.
- Export all entries as Markdown.
- Create a full backup.
- Restore from a backup on a clean or test install.

## Privacy And Settings

- Switch language between Chinese and English.
- Enable privacy lock and relaunch the app.
- Confirm Face ID / passcode unlock works.
- Disable privacy lock.

## Stability Notes

- Test on a real iPhone when possible.
- Restart the app after media, backup, and restore tests.
- Keep at least one backup before deleting or reinstalling the app.
