-- Log some debugging information
DROP TABLE IF EXISTS TERPO_debug_log;
CREATE TABLE TERPO_debug_log(objectId bigint, playerId TEXT, oldSlot TEXT, newSlot TEXT, lastSwitch integer);

-- Used to store the playerId and the old and new slots for the player that means to switch characters
DROP TABLE IF EXISTS TERPO_switches;
CREATE TABLE TERPO_switches(objectId bigint, playerId TEXT, oldSlot TEXT, newSlot TEXT, lastSwitch integer);

-- The trigger that fires whenever the mod inserts a row with the name MC_BP_TERPO_C.PlayerId
-- and the last newSlot recorded in TERPO_switches != newSlot
DROP TRIGGER IF EXISTS TERPO_char_switch;
CREATE TRIGGER TERPO_char_switch AFTER INSERT ON properties
WHEN NEW.name = 'MC_BP_TERPO_C.passToDB' AND ((SELECT newSlot FROM TERPO_switches WHERE objectId = NEW.object_id) != (SELECT CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),353,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),354,1)) - 1) FROM properties WHERE object_id = NEW.object_id AND name = 'MC_BP_TERPO_C.passToDB') OR (SELECT newSlot FROM TERPO_switches WHERE objectId = NEW.object_id) IS NULL)
BEGIN
	-- Remove any pre-existing TERPO_switches
	DELETE FROM TERPO_switches WHERE objectId = NEW.object_id;
	
	-- Insert a row with objectId, playerId, newSlot and oldSlot into TERPO_switches
	INSERT INTO TERPO_switches (objectId, playerId, oldSlot, newSlot, lastSwitch)
	VALUES (
		-- objectId
		(SELECT object_id FROM properties WHERE object_id = NEW.object_id AND name = 'MC_BP_TERPO_C.passToDB'),
		-- playerId (byte 165 to 198 of value BLOB)
		(SELECT CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),165,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),166,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),167,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),168,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),169,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),170,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),171,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),172,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),173,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),174,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),175,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),176,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),177,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),178,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),179,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),180,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),181,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),182,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),183,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),184,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),185,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),186,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),187,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),188,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),189,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),190,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),191,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),192,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),193,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),194,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),195,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),196,1)) - 1) || CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),197,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),198,1)) - 1) FROM properties WHERE object_id = NEW.object_id AND name = 'MC_BP_TERPO_C.passToDB'),
		-- oldSlot (byte 509 and 510 of value BLOB)
		(SELECT CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),509,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),510,1)) - 1) FROM properties WHERE object_id = NEW.object_id AND name = 'MC_BP_TERPO_C.passToDB'),
		-- newSlot (byte 353 and 354 of value BLOB)
		(SELECT CHAR((INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),353,1)) - 1) * 16 + INSTR('0123456789ABCDEF', SUBSTR(QUOTE(NEW.value),354,1)) - 1) FROM properties WHERE object_id = NEW.object_id AND name = 'MC_BP_TERPO_C.passToDB'),
		-- lastSwitch
		strftime('%s','now')
	);
	-- log all the values for debugging
	INSERT INTO TERPO_debug_log SELECT * FROM TERPO_switches WHERE objectId = NEW.object_id;

	-- append the old slot number to the row with playerId w/o any slot number
	UPDATE characters
	SET playerId = (SELECT playerId FROM TERPO_switches WHERE objectId = NEW.object_id) || (SELECT oldSlot FROM TERPO_switches WHERE objectId = NEW.object_id)	-- Set playerId = playerId + old slot
	WHERE playerId = (SELECT playerId FROM TERPO_switches WHERE objectId = NEW.object_id);																		-- Where playerId == playerId

	-- cut the slot number off the row with playerId with the new number
	UPDATE characters
	SET playerId = (SELECT playerId FROM TERPO_switches WHERE objectId = NEW.object_id)																				-- Set playerId = playerId
	WHERE playerId = (SELECT playerId FROM TERPO_switches WHERE objectId = NEW.object_id) || (SELECT newSlot FROM TERPO_switches WHERE objectId = NEW.object_id);	-- Where playerId == playerId + new slot
END;