ALTER table recipes DROP COLUMN book;
ALTER table recipes DROP COLUMN webLink;
ALTER table recipes ADD COLUMN source TEXT;

