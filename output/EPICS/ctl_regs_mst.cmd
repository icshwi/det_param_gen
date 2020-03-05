
dbLoadRecords("deviceID.db", SFX="DEVICE-DNA", SYS=$(SYS), COM=$(COM), REG0=0xc0001000, REG1=0xc0001004, REG2=0xc0001008, PRO=$(PROTO)")
dbLoadRecords("buildTime_register.db", SFX="BUILD-TIME", SYS=$(SYS), COM=$(COM), REG0=0xc000100c, PRO=$(PROTO)")
dbLoadRecords("githash_register.db", SFX="GIT-HASH", SYS=$(SYS), COM=$(COM), REG0=0xc0001010, REG1=0xc0001014, REG2=0xc0001018, PRO=$(PROTO)")
dbLoadRecords("reset_register.db", SFX="GLOBAL-RST", SYS=$(SYS), COM=$(COM), REG0=0xc000101c, PRO=$(PROTO)")
dbLoadRecords("RO_hex_register.db", SFX="PHASH", SYS=$(SYS), COM=$(COM), REG0=0xc0001020, PRO=$(PROTO)")
