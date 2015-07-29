SAVEPOINT upgrade_v0_8_passes;

ALTER TABLE PASSES ADD COLUMN
  pass_printed    TIMESTAMP WITH TIME ZONE NULL DEFAULT NULL;

UPDATE PASSES SET pass_printed = pass_issued;

RELEASE SAVEPOINT upgrade_v0_8_passes;
