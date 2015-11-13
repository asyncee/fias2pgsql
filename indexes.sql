-- extension to implement trigrams;
CREATE EXTENSION pg_trgm;


-- drop irrelevant data
DELETE FROM addrobj WHERE livestatus != 1 AND currstatus != 0;


--========== SOCRBASE ==========--

-- primary key (shortname)
-- ALTER TABLE socrbase DROP CONSTRAINT socrbase_pkey;
ALTER TABLE socrbase ADD CONSTRAINT socrbase_pkey PRIMARY KEY(kod_t_st);

CREATE UNIQUE INDEX kod_t_st_idx ON socrbase USING btree (kod_t_st);
CREATE INDEX scname_level_idx ON socrbase USING btree (scname, level);


--========== ADDROBJ ==========--


-- primary key (aoguid)
-- ALTER TABLE addrobj DROP CONSTRAINT addrobj_pkey;
ALTER TABLE addrobj ADD CONSTRAINT addrobj_pkey PRIMARY KEY(aoguid);


-- foreign key (parentguid to aoguid)
-- ALTER TABLE addrobj DROP CONSTRAINT addrobj_parentguid_fkey;
ALTER TABLE addrobj
  ADD CONSTRAINT addrobj_parentguid_fkey FOREIGN KEY (parentguid)
  REFERENCES addrobj (aoguid) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE NO ACTION;


--  create btree indexes
CREATE UNIQUE INDEX aoguid_pk_idx ON addrobj USING btree (aoguid);
CREATE UNIQUE INDEX aoid_idx ON addrobj USING btree (aoid);
CREATE INDEX parentguid_idx ON addrobj USING btree (parentguid);
CREATE INDEX currstatus_idx ON addrobj USING btree (currstatus);
CREATE INDEX aolevel_idx ON addrobj USING btree (aolevel);
CREATE INDEX formalname_idx ON addrobj USING btree (formalname);
CREATE INDEX offname_idx ON addrobj USING btree (offname);
CREATE INDEX shortname_idx ON addrobj USING btree (shortname);
CREATE INDEX shortname_aolevel_idx ON addrobj USING btree (shortname, aolevel);


-- trigram indexes to speed up text searches
CREATE INDEX formalname_trgm_idx on addrobj USING gin (formalname gin_trgm_ops);
CREATE INDEX offname_trgm_idx on addrobj USING gin (offname gin_trgm_ops);
