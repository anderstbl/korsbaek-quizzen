-- ============================================================
-- KORSBÆK QUIZ – Supabase Schema  (revideret & udvidet version)
-- Kør dette i Supabase SQL Editor (Database → SQL Editor → New Query)
-- Alle fakta verificeret mod matadoronline.dk karaktersider og episodeoversigter
-- ============================================================

-- ── QUESTIONS TABLE ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS questions (
  id          SERIAL PRIMARY KEY,
  type        VARCHAR(10)  NOT NULL,   -- 'fill' | 'who' | 'real' | 'fact'
  category    VARCHAR(30)  NOT NULL,   -- 'citat_fill' | 'citat_who' | 'citat_real' | 'handling' | 'tidslinje' | 'relation' | 'lokation' | 'billede'
  question    TEXT         NOT NULL,
  answer      TEXT         NOT NULL,
  options     JSONB,                   -- string array; NULL for 'real' type
  who         VARCHAR(100),            -- speaker, only for fill/who
  episode     INT,
  ep_title    VARCHAR(100),
  explanation TEXT,
  image_url   TEXT,                    -- URL til illustrationen (bruges af 'billede' kategori)
  active      BOOLEAN      DEFAULT true,
  created_at  TIMESTAMPTZ  DEFAULT NOW()
);

-- ── SCORES TABLE ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS scores (
  id            SERIAL PRIMARY KEY,
  name          VARCHAR(40)  NOT NULL,   -- spillerens navn (op til 40 tegn)
  score         INT          NOT NULL,
  correct       INT          DEFAULT 0,
  max_combo     INT          DEFAULT 0,
  speed_bonuses INT          DEFAULT 0,
  created_at    TIMESTAMPTZ  DEFAULT NOW()
);

-- ── ROW LEVEL SECURITY ───────────────────────────────────────
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE scores    ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS public_read_questions ON questions;
CREATE POLICY public_read_questions ON questions
  FOR SELECT TO anon USING (active = true);

DROP POLICY IF EXISTS public_read_scores ON scores;
CREATE POLICY public_read_scores ON scores
  FOR SELECT TO anon USING (true);

DROP POLICY IF EXISTS public_insert_scores ON scores;
CREATE POLICY public_insert_scores ON scores
  FOR INSERT TO anon WITH CHECK (true);

-- ── INDEXES ──────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_questions_type     ON questions(type);
CREATE INDEX IF NOT EXISTS idx_questions_category ON questions(category);
CREATE INDEX IF NOT EXISTS idx_scores_score       ON scores(score DESC);

-- ── TILFØJ image_url KOLONNE (sikkert hvis den allerede eksisterer) ──
ALTER TABLE questions ADD COLUMN IF NOT EXISTS image_url TEXT;

-- ── RYDDER EKSISTERENDE SPØRGSMÅL (sikker genindlæsning) ─────
-- Kør dette for at opdatere quiz-databasen uden dubletter:
DELETE FROM questions;

-- ============================================================
-- UDFYLD REPLIKEN (citat_fill) – verificeret fra manuskripterne
-- ============================================================
INSERT INTO questions (type, category, question, answer, options, who, episode, ep_title) VALUES

-- EP 1 – Den rejsende (1929)
('fill','citat_fill','Røde interesserer sig sgu ikke for kvinder kun for ___',
 'polletæk','["polletæk","bridgespil","sport","fodbold"]','GRISEHANDLEREN',1,'Den rejsende'),
('fill','citat_fill','Til pæne kjoler er det ikke ___ i denne sæson',
 'vinrødt','["vinrødt","sort","blåt","grønt"]','SCHWANN',1,'Den rejsende'),
('fill','citat_fill','Jeg forbyder nogen at røre ham, før han er blevet ___',
 'vasket','["vasket","undersøgt","klædt om","badet"]','MAUDE',1,'Den rejsende'),
('fill','citat_fill','Da De var rejst på ferie – fandt fruen ud af, at alle nøglehullerne de skulle renses med sprit og ___',
 'vatpinde','["vatpinde","en klud","børster","staniol"]','AGNES',1,'Den rejsende'),

-- EP 2 – Genboen (1929)
('fill','citat_fill','Agnes – den fejreste blandt Valhals ___',
 'Valkyrier','["Valkyrier","gudinder","damer","piger"]','BOLDT',2,'Genboen'),
('fill','citat_fill','Nej, det er osse mit navn. Andersen – ___',
 'Skjern','["Skjern","Jensen","Frederiksen","Hansen"]','MADS',2,'Genboen'),
('fill','citat_fill','Han lever nok af sine penge – den der tæller i enører, sanker i ___',
 'lade','["lade","banken","stilhed","pengepungen"]','BOLDT',2,'Genboen'),
('fill','citat_fill','Mens De fornøjede damerne – har min Kvik ___ Deres lille firbenede veninde',
 'lyksaliggjort','["lyksaliggjort","glædet","bidt","fornærmet"]','GRISEHANDLEREN',2,'Genboen'),

-- EP 3 – Skiftedag (1930)
('fill','citat_fill','Små eller store – jeg er ikke for ringe til at ___',
 'hilse','["hilse","bukke","bøje mig","vige"]','MADS',3,'Skiftedag'),
('fill','citat_fill','Vores kunder holder ikke ___',
 'skiftedag','["skiftedag","åbent søndag","sommerferie","lukket"]','SCHWANN',3,'Skiftedag'),

-- EP 4 – Skyggetanten (1931)
('fill','citat_fill','Selvom jeg er den ældste af os to – har jeg aldrig prøvet at rejse på andet end på ___ klasse',
 'tredje','["tredje","anden","første","fjerde"]','MADS',4,'Skyggetanten'),
('fill','citat_fill','Der er langt – fra Fredericia til ___',
 'Korsbæk','["Korsbæk","Herning","Viborg","Aarhus"]','KRISTEN',4,'Skyggetanten'),
('fill','citat_fill','Færdigsyet tøj, det er ikke noget for virkelige ___',
 'damer','["damer","kunder","kvinder","mennesker"]','SCHWANN',4,'Skyggetanten'),

-- EP 5 – Den enes død (1932)
('fill','citat_fill','Uden hende var jeg måske ikke så meget ___',
 'værd','["værd","glad","dygtig","heldig"]','MADS',5,'Den enes død'),
('fill','citat_fill','Banken tør ikke mere, Maude – jeg er ked af det, min ___',
 'skat','["skat","ven","elskede","kone"]','VARNÆS',5,'Den enes død'),

-- EP 6 – Opmarch (1932)
('fill','citat_fill','Ja, her ser De familiens ___ aktionær',
 'femte','["femte","sjette","fjerde","tredje"]','MADS',6,'Opmarch'),
('fill','citat_fill','Ja mig er der sgu ingen, der kalder op ___',
 'efter','["efter","til","på","om"]','GRISEHANDLEREN',6,'Opmarch'),
('fill','citat_fill','Derfor skal de ikke komme ind i en ordentlig forretning med folk i ___',
 'arbejdstøj','["arbejdstøj","mudderstøvler","det tøj","sådant tøj"]','SCHWANN',6,'Opmarch'),

-- EP 7 – Fødselsdagen (1933)
('fill','citat_fill','Tante Møghe bliver jo kun 100 år den ___ gang',
 'ene','["ene","første","samme","sidste"]','VARNÆS',7,'Fødselsdagen'),
('fill','citat_fill','Et flygel ___ du anskaffet dig, mindre kunne åbenbart ikke gøre det',
 'har','["har","fik","lod","måtte"]','MADS',7,'Fødselsdagen'),

-- EP 8 – Komme fremmede (1934)
('fill','citat_fill','Jeg skal ikke ___ nogen steder',
 'ferniseres','["ferniseres","udstilles","inviteres","fremvises"]','KATRINE',8,'Komme fremmede'),
('fill','citat_fill','I mit hjem havde vi et billede af Ruth, der sanker aks – og et af Jesus, der vandrer på ___',
 'søen','["søen","vandet","havet","bølgerne"]','RØDE',8,'Komme fremmede'),
('fill','citat_fill','Gammelt venskab er farligt for en ___',
 'bank','["bank","forretning","mand","by"]','SKJOLD HANSEN',8,'Komme fremmede'),

-- EP 9 – Hen til kommoden (1935)
('fill','citat_fill','Nu står du ved dit livs valg – mig – eller ___ og slip',
 'træk','["træk","kort","tov","snor"]','RØDE',9,'Hen til kommoden'),
('fill','citat_fill','Dine frikadeller er forhåbentlig ___',
 'bedre','["bedre","gode","store","færdige"]','KATRINE',9,'Hen til kommoden'),

-- EP 10 – I disse tider (1935)
('fill','citat_fill','Ja, I er jo mænd – så koster respekten heller ikke ___',
 'noget','["noget","meget","penge","tid"]','INGEBORG',10,'I disse tider'),
('fill','citat_fill','Det er i hvert fald et held, hun ikke har giftet sig med ___',
 'Kristen','["Kristen","Jørgen","Holmdal","Varnæs"]','MADS',10,'I disse tider'),

-- EP 11 – I klemme (1936)
('fill','citat_fill','Jeg er døbt, konfirmeret og betaler kirkeskat – og dermed ___',
 'basta','["basta","punktum","færdig","slut"]','SKJOLD HANSEN',11,'I klemme'),
('fill','citat_fill','I ka da ikke ordne ___ i de omgivelser',
 'verdensrevolutionen','["verdensrevolutionen","politikken","klassekampen","krigen"]','GRISEHANDLEREN',11,'I klemme'),
('fill','citat_fill','Aldrig! Kun når jeg bliver ___!',
 'opdaget','["opdaget","stoppet","afsløret","taget"]','DR. HANSEN',11,'I klemme'),

-- EP 12 – I lyst og nød (1936–37)
('fill','citat_fill','Hvorfor faen ku du ikke osse bare nøjes med at være en ganske almindlig ___!?',
 'socialdemokrat','["socialdemokrat","arbejder","borger","dansker"]','GRISEHANDLEREN',12,'I lyst og nød'),
('fill','citat_fill','Det er ikke fluer, han skal slå ihjel – det er ___',
 'svin','["svin","fjender","fascister","tyskere"]','KATRINE',12,'I lyst og nød'),
('fill','citat_fill','Og så kan du køre i rullestol op og ned ad gaden – lissom ___',
 'fru Møghe','["fru Møghe","en gammel mand","de andre","en invalid"]','AGNES',12,'I lyst og nød');

-- ============================================================
-- HVEM SAGDE DET? (citat_who) – verificeret fra manuskripterne
-- ============================================================
INSERT INTO questions (type, category, question, answer, options, episode, ep_title) VALUES

('who','citat_who','"Du er en KEDELIG, GAMMEL, OND mand"',
 'VICKI','["VICKI","INGEBORG","MAUDE","AGNES"]',4,'Skyggetanten'),
('who','citat_who','"Den fejreste blandt Valhals Valkyrier"',
 'BOLDT','["BOLDT","GRISEHANDLEREN","VARNÆS","JØRGEN"]',2,'Genboen'),
('who','citat_who','"Det var dog satans så fræk hun er blevet – hun ta''r mere og mere efter sin mor"',
 'GRISEHANDLEREN','["GRISEHANDLEREN","BOLDT","SKJOLD HANSEN","RØDE"]',6,'Opmarch'),
('who','citat_who','"Jeg vil hellere arbejde gratis for hende – end hos dem, derovre. De slog Albert ihjel!"',
 'FRK. JØRGENSEN','["FRK. JØRGENSEN","VICKI","MAUDE","VIOLET"]',6,'Opmarch'),
('who','citat_who','"Herbert er mit vidne – det smukkeste barn Korsbæk har set"',
 'RØDE','["RØDE","GRISEHANDLEREN","BOLDT","FEDE"]',11,'I klemme'),
('who','citat_who','"Nåhhh – hr. og fru Skjern er da flinke nok – min fru har i hvert fald ingen bacilleanfald"',
 'GUDRUN','["GUDRUN","LAURA","AGNES","KATRINE"]',9,'Hen til kommoden'),
('who','citat_who','"Det grimme skrummel"',
 'FRU MØGHE','["FRU MØGHE","MISSE","VARNÆS","STEIN"]',9,'Hen til kommoden'),
('who','citat_who','"Og hver engang at døren gik, jeg tro''de det var dig..."',
 'FRK. MORTENSEN','["FRK. MORTENSEN","ULLA","FRK. JØRGENSEN","AGNES"]',8,'Komme fremmede'),
('who','citat_who','"Sans comparaison – min skat"',
 'VARNÆS','["VARNÆS","JØRGEN","HOLMDAL","KONSULEN"]',10,'I disse tider'),
('who','citat_who','"Nja – så er jeg bange for at Albert krakker!"',
 'VARNÆS','["VARNÆS","GRISEHANDLEREN","HOLMDAL","BOLDT"]',3,'Skiftedag'),
('who','citat_who','"Ja, min mand regner med, det bliver en dreng"',
 'INGEBORG','["INGEBORG","AGNES","MAUDE","KATRINE"]',6,'Opmarch'),
('who','citat_who','"Fordi det er med en herre"',
 'INGEBORG','["INGEBORG","MAUDE","LAURA","VICKI"]',5,'Den enes død'),
('who','citat_who','"Det er pænt af konsulinden, at hun vil frelse min sjæl"',
 'ELISABETH','["ELISABETH","VICKI","ULLA","AGNES"]',11,'I klemme'),
('who','citat_who','"Jeg begriber ikke, du kan – jeg kan ikke engang holde ud at høre mig selv spille"',
 'MAUDE','["MAUDE","VARNÆS","INGEBORG","VICKI"]',12,'I lyst og nød'),
('who','citat_who','"Man skulle tro, jeg forlod dig for en anden kvinde – sådan som du tager på vej"',
 'RØDE','["RØDE","JØRGEN","KRISTEN","HOLMDAL"]',12,'I lyst og nød'),
('who','citat_who','"Hvis de endda sad – de har dem sgu i strømpeskafterne"',
 'GRISEHANDLEREN','["GRISEHANDLEREN","BOLDT","RØDE","VARNÆS"]',6,'Opmarch'),
('who','citat_who','"Giftes – allerede – hvor gammel er De da, Agnes?"',
 'MAUDE','["MAUDE","INGEBORG","LAURA","FRU MØGHE"]',9,'Hen til kommoden'),
('who','citat_who','"Jeg er 24"',
 'AGNES','["AGNES","ULLA","REGITZE","GITTE"]',9,'Hen til kommoden'),
('who','citat_who','"Det er den heller ikke, lille mor"',
 'MISSE','["MISSE","KATRINE","INGEBORG","AGNES"]',9,'Hen til kommoden'),
('who','citat_who','"Hellere for lidt end for meget. I Arnesens tid måtte vi klatre over møblerne"',
 'ELISABETH','["ELISABETH","VICKI","MAUDE","INGEBORG"]',7,'Fødselsdagen');

-- ============================================================
-- ÆGTE ELLER OPFUNDET? (citat_real)
-- ============================================================
INSERT INTO questions (type, category, question, answer, options, episode, ep_title, explanation) VALUES

('real','citat_real','"Røde interesserer sig sgu ikke for kvinder kun for polletæk"',
 'ÆGTE',NULL,1,'Den rejsende',
 'Grisehandlerens replik fra ep.1 – han sidder i jernbanerestauranten og iagttager de to unge mænd.'),
('real','citat_real','"Du er en KEDELIG, GAMMEL, OND mand"',
 'ÆGTE',NULL,4,'Skyggetanten',
 'Vickis rasende udbrud til Arnesen i ep.4, da han knækker hendes nye rejsegrammofon.'),
('real','citat_real','"I Korsbæk kender alle hinanden – for godt, sommetider"',
 'LØGN',NULL,NULL,NULL,
 'Opfundet – lyder Matador-agtig, men optræder ikke i de originale manuskripter.'),
('real','citat_real','"Agnes – den fejreste blandt Valhals Valkyrier"',
 'ÆGTE',NULL,2,'Genboen',
 'Boldts flirtende hilsen til Agnes i jernbanerestauranten, ep.2 "Genboen".'),
('real','citat_real','"En god handelsmand sælger ikke varer – han sælger drømme"',
 'LØGN',NULL,NULL,NULL,
 'Opfundet i Mads Skjerns stil – men han siger aldrig noget så svulstig i manuskripterne.'),
('real','citat_real','"Gammelt venskab er farligt for en bank"',
 'ÆGTE',NULL,8,'Komme fremmede',
 'Skjold Hansens kolde bemærkning i ep.8, mens han rydder ud i Korsbæk Banks gamle kunder.'),
('real','citat_real','"Banken er som en kirke – man kommer der i nød, men sjældent i glæde"',
 'LØGN',NULL,NULL,NULL,
 'Opfundet – for vittigt til Varnæs'' formelle stil og optræder ikke i nogen episode.'),
('real','citat_real','"Jeg er døbt, konfirmeret og betaler kirkeskat – og dermed basta"',
 'ÆGTE',NULL,11,'I klemme',
 'Skjold Hansens bramfri svar i ep.11, da hans kone presser ham til at deltage i Oxford-bevægelsen.'),
('real','citat_real','"Hvorfor faen ku du ikke osse bare nøjes med at være en ganske almindlig socialdemokrat!?"',
 'ÆGTE',NULL,12,'I lyst og nød',
 'Grisehandlerens bramfrie udbrud til Røde i ep.12, da han får nys om hans planer om at drage til Spanien.'),
('real','citat_real','"Man skal ikke dømme en mand på hans konto, men på hans karakter"',
 'LØGN',NULL,NULL,NULL,
 'Opfundet – lyder fornuftigt nok, men optræder ikke i nogen af manuskripterne.'),
('real','citat_real','"Dine frikadeller er forhåbentlig bedre"',
 'ÆGTE',NULL,9,'Hen til kommoden',
 'Katrines tørre kommentar til Agnes i ep.9 – bedre end Rødes politiske teorier, formentlig.'),
('real','citat_real','"Agnes, du er den eneste kvinde, jeg nogensinde har elsket"',
 'LØGN',NULL,NULL,NULL,
 'Opfundet – Røde er ikke manden for store romantiske erklæringer i manuskripterne.'),
('real','citat_real','"Han lever nok af sine penge – den der tæller i enører, sanker i lade"',
 'ÆGTE',NULL,2,'Genboen',
 'Boldts skarpe karakteristik af den nye genbo Mads Andersen-Skjern over for Agnes, ep.2.'),
('real','citat_real','"I Korsbæk er der ikke plads til de store følelser"',
 'LØGN',NULL,NULL,NULL,
 'Opfundet – ingen i serien siger noget så selvbevidst refleksivt om Korsbæk.'),
('real','citat_real','"Det er ikke fluer, han skal slå ihjel – det er svin"',
 'ÆGTE',NULL,12,'I lyst og nød',
 'Katrines karakteristik i ep.12 – grisehandlerens kone er ikke bleg for at kalde en spade en spade.'),
('real','citat_real','"Færdigsyet tøj, det er ikke noget for virkelige damer"',
 'ÆGTE',NULL,4,'Skyggetanten',
 'Schwanns stolte bemærkning i butikken – for hende er skræddersyet tøj den eneste rigtige løsning.'),
('real','citat_real','"En forretning er som et ægteskab – man skal plejes hele tiden"',
 'LØGN',NULL,NULL,NULL,
 'Opfundet – ingen af forretningsmændene i Korsbæk ytrer sig så blomstrende om handel.'),
('real','citat_real','"Nu står du ved dit livs valg – mig – eller træk og slip"',
 'ÆGTE',NULL,9,'Hen til kommoden',
 'Rødes ultimatum til Agnes i ep.9 – alt eller intet i hans direkte stil.'),
('real','citat_real','"En dame rejser aldrig på tredje klasse"',
 'LØGN',NULL,NULL,NULL,
 'Opfundet – Mads siger noget lignende om sig selv i ep.4, men ingen udtaler netop dette.'),
('real','citat_real','"Jeg er 24"',
 'ÆGTE',NULL,9,'Hen til kommoden',
 'Agnes'' svar til Maude i ep.9, da konsulinden spørger forbavset til hendes alder ved gifteplanerne.'),
('real','citat_real','"Og så kan du køre i rullestol op og ned ad gaden – lissom fru Møghe"',
 'ÆGTE',NULL,12,'I lyst og nød',
 'Agnes'' bidende kommentar til Røde i ep.12, da han overvejer at drage i krig.'),
('real','citat_real','"En konsul er ikke en mand – han er en institution"',
 'LØGN',NULL,NULL,NULL,
 'Opfundet – lyder som noget Mads kunne sige, men optræder ikke i manuskripterne.'),
('real','citat_real','"Jeg begriber ikke, du kan – jeg kan ikke engang holde ud at høre mig selv spille"',
 'ÆGTE',NULL,12,'I lyst og nød',
 'Maudes ærlige indrømmelse om sit klaverspil i ep.12.'),
('real','citat_real','"Det var dog satans, så fræk hun er blevet"',
 'ÆGTE',NULL,6,'Opmarch',
 'Grisehandlerens bramfrie bemærkning om Ellen Skjern i ep.6, da hun snobber opad.'),
('real','citat_real','"Penge lugter ikke"',
 'LØGN',NULL,NULL,NULL,
 'Dette latinske ordsprog kendes fra Vespasian, men siges ikke af nogen i Matadors manuskripter.');

-- ============================================================
-- HANDLING (plot) – verificeret mod matadoronline.dk
-- ============================================================
INSERT INTO questions (type, category, question, answer, options, episode, ep_title) VALUES

('fact','handling','Hvad hedder Mads Skjerns allerførste butik i Korsbæk?',
 'Tøjhuset',
 '["Tøjhuset","Skjerns Magasin","Damernes Magasin","Korsbæk Mode"]',
 1,'Den rejsende'),

('fact','handling','Hvad hedder butikken Albert Arnesen ejer og driver i Korsbæk?',
 'Damernes Magasin',
 '["Damernes Magasin","Tøjhuset","Skjerns Manufaktur","Arnesens Mode"]',
 1,'Den rejsende'),

('fact','handling','Hvad omdøber Mads sin butik til i 1933?',
 'Skjerns Magasin',
 '["Skjerns Magasin","Korsbæk Varehus","Tøjhuset","Andersen-Skjerns"]',
 NULL,NULL),

('fact','handling','Hvem er direktør for Omegnsbanken, da den åbner i 1932?',
 'Kristen Skjern',
 '["Kristen Skjern","Mads Skjern","Skjold Hansen","Hans Christian Varnæs"]',
 NULL,NULL),

('fact','handling','Hvad sker der med Albert Arnesens forretning i ep.3 "Skiftedag"?',
 'Konkurrenten Tøjhuset åbner på den anden side af gaden',
 '["Konkurrenten Tøjhuset åbner på den anden side af gaden","Han sælger forretningen til Mads","Han åbner filial i Aarhus","Han vinder en stor ordre"]',
 3,'Skiftedag'),

('fact','handling','Hvem dør i episoden "Den enes død"?',
 'Albert Arnesen',
 '["Albert Arnesen","Laura Sørensen","Ingeborg Skjern","Fru Møghe"]',
 5,'Den enes død'),

('fact','handling','Hvad er årsagen til Albert Arnesens død i 1932?',
 'Hjertestop efter konkurs – banken vendte ham ryggen',
 '["Hjertestop efter konkurs – banken vendte ham ryggen","Selvmord","Sygdom","En ulykke"]',
 5,'Den enes død'),

('fact','handling','Hvad fejres i episoden "Fødselsdagen"?',
 'Fru Møghes 100-årsdag – der dog viser sig at være en misforståelse',
 '["Fru Møghes 100-årsdag – der dog viser sig at være en misforståelse","Mads'' 50-årsdag","Agnes og Rødes bryllup","Varnæs'' jubilæum"]',
 7,'Fødselsdagen'),

('fact','handling','Hvad engagerer Maude Varnæs sig i ep.11 "I klemme"?',
 'Oxford-bevægelsen',
 '["Oxford-bevægelsen","Kommunistpartiet","Kvindernes Handelsforening","Socialdemokratiet"]',
 11,'I klemme'),

('fact','handling','Hvad planlægger Røde at gøre i ep.12 "I lyst og nød"?',
 'Rejse til Spanien og kæmpe i borgerkrigen',
 '["Rejse til Spanien og kæmpe i borgerkrigen","Starte en avis","Flytte til København","Åbne en butik"]',
 12,'I lyst og nød'),

('fact','handling','Hvem ankommer til Korsbæk i ep.8 "Komme fremmede"?',
 'Den kendte maler Ernst Nyborg',
 '["Den kendte maler Ernst Nyborg","En ny bankdirektør","Ingeborgs familie fra Fredericia","En tysk flygtning"]',
 8,'Komme fremmede'),

('fact','handling','Hvad er Ernst Nyborg for Maude Varnæs?',
 'Hendes tidligere tegnelærer og kæreste',
 '["Hendes tidligere tegnelærer og kæreste","Hendes onkel","En gammel ven af Varnæs","En berømt forfatter"]',
 8,'Komme fremmede'),

('fact','handling','Hvad beslutter Agnes sig for i ep.9 "Hen til kommoden"?',
 'At sige ja til Rødes frieri',
 '["At sige ja til Rødes frieri","At rejse til København","At sige op hos Varnæs","At flytte til udlandet"]',
 9,'Hen til kommoden'),

('fact','handling','Hvad er Rødes rigtige navn?',
 'Lauritz Jensen',
 '["Lauritz Jensen","Herbert Schmidt","Rudolf Jensen","Lars Jensen"]',
 NULL,NULL),

('fact','handling','Hvad driver Grisehandler Oluf Larsen som erhverv?',
 'Handel med grise',
 '["Handel med grise","Et bageri","Et jernstøberi","En møbelfabrik"]',
 NULL,NULL),

('fact','handling','Hvad er Boldt Severins stilling i Korsbæk?',
 'Tjener på Jernbane Hotellet',
 '["Tjener på Jernbane Hotellet","Bankdirektør","Manufakturhandler","Politimand"]',
 NULL,NULL),

('fact','handling','Hvad er Misse Møghes relation til Fru Møghe?',
 'Hun er Fru Møghes datter',
 '["Hun er Fru Møghes datter","Hun er Fru Møghes niece","Hun er Fru Møghes husholderske","Hun er Fru Møghes barnebarn"]',
 NULL,NULL),

('fact','handling','Hvad starter Agnes som selvstændig virksomhed?',
 'Strømpemaskeri',
 '["Strømpemaskeri","Modeboutique","Bageri","Vaskeri"]',
 NULL,NULL),

('fact','handling','Hvad hedder det skuespil Herbert Schmidt skriver om sine oplevelser i Spanien?',
 'Støvlerne',
 '["Støvlerne","Krigen","Spanierne","Fremmed i Europa"]',
 NULL,NULL),

('fact','handling','Hvor sættes Herberts skuespil "Støvlerne" op i 1940?',
 'Det Ny Teater i København',
 '["Det Ny Teater i København","Det Kongelige Teater","Aarhus Teater","Odense Teater"]',
 NULL,NULL),

('fact','handling','Hvad er Herbert Schmidt?',
 'Tysk kommunistisk digter og flygtning',
 '["Tysk kommunistisk digter og flygtning","Dansk maler","Østrigsk musiker","Norsk journalist"]',
 NULL,NULL),

('fact','handling','Hvad gør Røde i 1941?',
 'Går under jorden og flygter siden til Sverige',
 '["Går under jorden og flygter siden til Sverige","Melder sig til tyskerne","Åbner bureau i Korsbæk","Rejser til Amerika"]',
 NULL,NULL),

('fact','handling','Hvad sker der med Oluf Larsen i 1943?',
 'Fængsles i 30 dage af tyskerne – han har hængt et billede af Hitler under lokumsbræt',
 '["Fængsles i 30 dage af tyskerne – han har hængt et billede af Hitler under lokumsbræt","Skyder en tysk soldat","Smugler jøder til Sverige","Saboterer en fabrik"]',
 NULL,NULL),

('fact','handling','Hvad stiller Røde op til i 1946?',
 'Folketing-valget – han vælges ikke',
 '["Folketing-valget – han vælges ikke","Borgmesterpost i Korsbæk","Formand i kommunistpartiet","Valg til byrådet"]',
 NULL,NULL),

('fact','handling','Hvad er Holmdal Aages stilling i Korsbæk Bank?',
 'Volontør',
 '["Volontør","Bankdirektør","Kasserer","Revisor"]',
 NULL,NULL),

('fact','handling','Hvad hedder pekingeseren der er Vickis eneste holdepunkt i København?',
 'Daisy',
 '["Daisy","Pixie","Bella","Lotte"]',
 NULL,NULL),

('fact','handling','Hvad spiller Doktor Hansen i den musikalske trio med Elisabeth og Kristen?',
 'Cello',
 '["Cello","Violin","Klaver","Fløjte"]',
 NULL,NULL),

('fact','handling','Hvad omdøbes Jernbane Hotellet til af Boldt og Ada?',
 'Rosenhaven',
 '["Rosenhaven","Korsbæk Kro","Jernbanepavillonen","Stationshotellet"]',
 NULL,NULL),

('fact','handling','Hvad åbner Mads Skjern i 1935 i Korsbæk?',
 'En konfektionsfabrik',
 '["En konfektionsfabrik","En bank","Et varehus","Et lager"]',
 NULL,NULL),

('fact','handling','Hvad udnævnes Mads Skjern til i 1946?',
 'Ridder af Dannebrog',
 '["Ridder af Dannebrog","Borgmester","Konsul","Storkors af Dannebrog"]',
 NULL,NULL),

('fact','handling','Hvad udnævnes Mads Skjern til i 1947?',
 'Svensk konsul',
 '["Svensk konsul","Britisk konsul","Borgmester i Korsbæk","Formand for Dansk Industri"]',
 NULL,NULL),

('fact','handling','Hvad er Doktor Hansens politiske tilhørsforhold?',
 'De Radikale',
 '["De Radikale","Socialdemokratiet","Venstre","Konservative"]',
 NULL,NULL),

('fact','handling','Hvem hjælper Maude Varnæs med at flygte til Sverige i 1943?',
 'Jøden hr. Stein',
 '["Jøden hr. Stein","Herbert Schmidt","Røde Jensen","Baron von Rydtger"]',
 NULL,NULL),

('fact','handling','Hvad sker der med Schwann i 1932?',
 'Han mister sin formue og sit job, da Damernes Magasin krakker',
 '["Han mister sin formue og sit job, da Damernes Magasin krakker","Han åbner sin egen butik","Han rejser til udlandet","Han bliver direktør for Omegnsbanken"]',
 NULL,NULL),

('fact','handling','Hvad laver Schwann efter Damernes Magasin krakker?',
 'Inkassator',
 '["Inkassator","Tjener","Manufakturhandler","Sælger"]',
 NULL,NULL),

('fact','handling','Hvem bejler til Elisabeth Friis uden held?',
 'Doktor Hansen',
 '["Doktor Hansen","Jørgen Varnæs","Mads Skjern","Baron von Rydtger"]',
 NULL,NULL),

('fact','handling','Hvad bygger Mads sin butik om til i 1937?',
 'Et varehus',
 '["Et varehus","Et lager","En fabrik","En bank"]',
 NULL,NULL),

('fact','handling','Hvem leder modstandsbevægelsen i Korsbæk?',
 'Doktor Hansen',
 '["Doktor Hansen","Kristen Skjern","Røde Jensen","Hans Christian Varnæs"]',
 NULL,NULL),

('fact','handling','Hvad er Ernst Nyborgs hjemby?',
 'Tibirke',
 '["Tibirke","Hillerød","Helsingør","Fredensborg"]',
 NULL,NULL),

('fact','handling','Hvad hedder Baron von Rydtgers gods?',
 'Brydesø Slot',
 '["Brydesø Slot","Varnæsgaard","Skjernsgaard","Holmegaard"]',
 NULL,NULL),

('fact','handling','Hvad var Mads Skjern inden han kom til Korsbæk?',
 'Enkemand og rejsende fra det indremissionske Vestjylland',
 '["Enkemand og rejsende fra det indremissionske Vestjylland","Bankdirektør i Aarhus","Læge i Fredericia","Grossist i København"]',
 NULL,NULL),

('fact','handling','Hvad gør Daniel Skjern i Paris fra 1945?',
 'Lærer haute couture fra bunden',
 '["Lærer haute couture fra bunden","Studerer jura","Arbejder på en bank","Skriver romaner"]',
 NULL,NULL),

('fact','handling','Hvad er Katrines politiske parti?',
 'Venstre',
 '["Venstre","Socialdemokratiet","Konservative","De Radikale"]',
 NULL,NULL),

('fact','handling','Hvad er Mads Skjerns relation til den indremissionske bevægelse?',
 'Han er opvokset i det indremissionske Vestjylland',
 '["Han er opvokset i det indremissionske Vestjylland","Han er aktiv leder af bevægelsen","Han er modstander af bevægelsen","Han er gift med en prædikants datter"]',
 NULL,NULL);

-- ============================================================
-- TIDSLINJE (timeline)
-- ============================================================
INSERT INTO questions (type, category, question, answer, options, episode, ep_title) VALUES

('fact','tidslinje','Hvilken periode foregår de 12 første episoder af Matador i?',
 '1929–1937',
 '["1929–1937","1920–1935","1930–1947","1925–1940"]',
 NULL,NULL),

('fact','tidslinje','I hvilken episode ankommer Mads Andersen-Skjern til Korsbæk?',
 'Episode 1 – Den rejsende',
 '["Episode 1 – Den rejsende","Episode 2 – Genboen","Episode 3 – Skiftedag","Episode 4 – Skyggetanten"]',
 NULL,NULL),

('fact','tidslinje','Hvad hedder den episode, der rummer historien om Albert Arnesens død?',
 'Den enes død',
 '["Den enes død","Skiftedag","I klemme","I disse tider"]',
 NULL,NULL),

('fact','tidslinje','Hvornår foregår ep.1 "Den rejsende"?',
 '1929',
 '["1929","1928","1930","1931"]',
 1,'Den rejsende'),

('fact','tidslinje','Hvornår foregår ep.12 "I lyst og nød"?',
 '1936–1937',
 '["1936–1937","1934–1935","1938–1939","1940–1941"]',
 12,'I lyst og nød'),

('fact','tidslinje','I hvilken episode gifter Agnes sig med Røde?',
 'Episode 10 – I disse tider',
 '["Episode 10 – I disse tider","Episode 9 – Hen til kommoden","Episode 11 – I klemme","Episode 8 – Komme fremmede"]',
 NULL,NULL),

('fact','tidslinje','I hvilken episode ankommer den kendte maler Ernst Nyborg til Korsbæk?',
 'Episode 8 – Komme fremmede',
 '["Episode 8 – Komme fremmede","Episode 6 – Opmarch","Episode 5 – Den enes død","Episode 7 – Fødselsdagen"]',
 NULL,NULL),

('fact','tidslinje','Hvad hedder ep.7?',
 'Fødselsdagen',
 '["Fødselsdagen","Genboen","Skyggetanten","I klemme"]',
 7,'Fødselsdagen'),

('fact','tidslinje','Hvad hedder ep.3?',
 'Skiftedag',
 '["Skiftedag","Skyggetanten","Genboen","Opmarch"]',
 3,'Skiftedag'),

('fact','tidslinje','Hvornår foregår ep.6 "Opmarch"?',
 '1932',
 '["1932","1930","1933","1934"]',
 6,'Opmarch'),

('fact','tidslinje','I hvilken episode finder Røde og Agnes lejlighed hos familien Larsen?',
 'Episode 9 – Hen til kommoden',
 '["Episode 9 – Hen til kommoden","Episode 10 – I disse tider","Episode 8 – Komme fremmede","Episode 11 – I klemme"]',
 9,'Hen til kommoden'),

('fact','tidslinje','Hvornår åbner Mads Tøjhuset i Korsbæk?',
 '1929',
 '["1929","1930","1931","1928"]',
 NULL,NULL),

('fact','tidslinje','Hvornår gifter Mads Andersen-Skjern sig med Ingeborg?',
 '1930',
 '["1930","1929","1931","1932"]',
 NULL,NULL),

('fact','tidslinje','Hvornår åbner Omegnsbanken?',
 '1932',
 '["1932","1930","1933","1931"]',
 NULL,NULL),

('fact','tidslinje','Hvornår omdøbes Tøjhuset til Skjerns Magasin?',
 '1933',
 '["1933","1932","1934","1935"]',
 NULL,NULL),

('fact','tidslinje','Hvornår ankommer Herbert Schmidt til Korsbæk?',
 '1935',
 '["1935","1933","1936","1934"]',
 NULL,NULL),

('fact','tidslinje','Hvornår gifter Agnes og Røde sig?',
 '1935',
 '["1935","1934","1936","1933"]',
 NULL,NULL),

('fact','tidslinje','Hvornår dør Fru Fernando Møghe?',
 '1942',
 '["1942","1940","1944","1939"]',
 NULL,NULL),

('fact','tidslinje','Hvornår besætter Tyskland Danmark?',
 '9. april 1940',
 '["9. april 1940","1. september 1939","1. april 1940","9. april 1941"]',
 NULL,NULL),

('fact','tidslinje','Hvornår befries Danmark?',
 '5. maj 1945',
 '["5. maj 1945","8. maj 1945","1. maj 1945","17. maj 1945"]',
 NULL,NULL),

('fact','tidslinje','Hvornår fejrer Mads Skjern sin 50-årsdag?',
 '1947',
 '["1947","1945","1946","1948"]',
 NULL,NULL),

('fact','tidslinje','Hvornår sættes Herberts stykke "Støvlerne" op på Det Ny Teater?',
 '1940',
 '["1940","1939","1941","1942"]',
 NULL,NULL),

('fact','tidslinje','Hvornår køber Mads sommerhus på Fedet?',
 '1931',
 '["1931","1930","1932","1933"]',
 NULL,NULL),

('fact','tidslinje','Hvornår dør Albert Arnesen?',
 '1932',
 '["1932","1930","1933","1931"]',
 5,'Den enes død');

-- ============================================================
-- RELATIONER (character relations) – verificeret mod matadoronline.dk
-- ============================================================
INSERT INTO questions (type, category, question, answer, options, episode, ep_title) VALUES

('fact','relation','Hvad er Agnes'' stilling hos familien Varnæs?',
 'Stuepige',
 '["Stuepige","Kokkepige","Barnepige","Husholderske"]',
 NULL,NULL),

('fact','relation','Hvad hedder Mads Andersen-Skjerns hustru?',
 'Ingeborg',
 '["Ingeborg","Maude","Agnes","Katrine"]',
 NULL,NULL),

('fact','relation','Hvad er Ingeborgs relation til Grisehandler Oluf Larsen?',
 'Hun er hans datter',
 '["Hun er hans datter","Hun er hans niece","Hun er hans nabo","Hun er hans søster"]',
 NULL,NULL),

('fact','relation','Hvem er konsul Varnæs gift med?',
 'Maude',
 '["Maude","Agnes","Ingeborg","Elisabeth"]',
 NULL,NULL),

('fact','relation','Hvad er Jørgen Varnæs'' relation til konsul Hans Christian Varnæs?',
 'Han er Hans Christians lillebror',
 '["Han er Hans Christians lillebror","Han er Hans Christians søn","Han er Hans Christians nevø","Han er Hans Christians forretningspartner"]',
 NULL,NULL),

('fact','relation','Hvad er Elisabeth Friis'' relation til Maude Varnæs?',
 'Hun er Maudes storesøster',
 '["Hun er Maudes storesøster","Hun er Maudes husbestyrerinde","Hun er Maudes kusine","Hun er Maudes veninde"]',
 NULL,NULL),

('fact','relation','Hvad er Katrines relation til Ingeborg Skjern?',
 'Katrine er Ingeborgs mor',
 '["Katrine er Ingeborgs mor","Katrine er Ingeborgs tante","Katrine er Ingeborgs søster","Katrine er Ingeborgs veninde"]',
 NULL,NULL),

('fact','relation','Hvad er forholdet mellem Mads og Albert Arnesen?',
 'De er forretningsmæssige rivaler i manufakturbranchen',
 '["De er forretningsmæssige rivaler i manufakturbranchen","De er barndomsvenner","De er søskende","De er kompagnoner"]',
 NULL,NULL),

('fact','relation','Hvad er Jørgen Varnæs'' erhverv?',
 'Overretssagfører',
 '["Overretssagfører","Bankdirektør","Grossist","Ingeniør"]',
 NULL,NULL),

('fact','relation','Hvad er Hans Christian Varnæs'' stilling i Korsbæk?',
 'Direktør for Korsbæk Bank',
 '["Direktør for Korsbæk Bank","Borgmester","Grossist","Politimester"]',
 NULL,NULL),

('fact','relation','Hvad er Skjold Hansens erhverv?',
 'Landsretssagfører',
 '["Landsretssagfører","Bankdirektør","Grossist","Ingeniør"]',
 NULL,NULL),

('fact','relation','Hvad er Maude Varnæs'' pigenavn?',
 'Friis',
 '["Friis","Larsen","Hansen","Møghe"]',
 NULL,NULL),

('fact','relation','Hvad er dr. Hansen i Korsbæk?',
 'Byens læge',
 '["Byens læge","Tandlæge","Apoteker","Hospitalsdirektør"]',
 NULL,NULL),

('fact','relation','Hvem er Grisehandler Oluf Larsens hustru?',
 'Katrine',
 '["Katrine","Agnes","Misse","Gudrun"]',
 NULL,NULL),

('fact','relation','Hvilke tre børn har Hans Christian og Maude Varnæs?',
 'Ulrik, Regitze og Helle',
 '["Ulrik, Regitze og Helle","Jørgen, Ulrik og Regitze","Ulrik, Helle og Vicki","Regitze, Helle og Gitte"]',
 NULL,NULL),

('fact','relation','Hvad er Agnes'' pigenavn (vor 1935)?',
 'Ruud',
 '["Ruud","Larsen","Jensen","Hansen"]',
 NULL,NULL),

('fact','relation','Hvem er Daniels biologiske far?',
 'Mads Skjern',
 '["Mads Skjern","Holger Jørgensen","Hans Christian Varnæs","Kristen Skjern"]',
 NULL,NULL),

('fact','relation','Hvem er Ellens biologiske far?',
 'Holger Jørgensen',
 '["Holger Jørgensen","Mads Skjern","Oluf Larsen","Røde Jensen"]',
 NULL,NULL),

('fact','relation','Hvad er Fru Møghes relation til Hans Christian Varnæs?',
 'Hun er hans tante og gudmor',
 '["Hun er hans tante og gudmor","Hun er hans mormor","Hun er hans nabo","Hun er hans moster"]',
 NULL,NULL),

('fact','relation','Hvem er Vicki Hachels far?',
 'Oberst Ditlev Hachel',
 '["Oberst Ditlev Hachel","Albert Arnesen","Hans Christian Varnæs","Baron von Rydtger"]',
 NULL,NULL),

('fact','relation','Hvem er Ulla Jacobsens tante?',
 'Violet Vinter',
 '["Violet Vinter","Katrine Larsen","Misse Møghe","Elisabeth Friis"]',
 NULL,NULL),

('fact','relation','Hvem er Ingeborgs første mand inden Mads?',
 'Holger Jørgensen',
 '["Holger Jørgensen","Kristen Skjern","Aage Holmdal","Oluf Larsen"]',
 NULL,NULL),

('fact','relation','Hvad hedder Agnes og Rødes to sønner?',
 'Aksel og Knud',
 '["Aksel og Knud","Erik og Daniel","Ulrik og Jørgen","Mogens og Poul"]',
 NULL,NULL),

('fact','relation','Hvem gifter Kristen Skjern sig med til sidst (i 1946)?',
 'Elisabeth Friis',
 '["Elisabeth Friis","Iben Skjold Hansen","Gitte Graa","Ulla Jacobsen"]',
 NULL,NULL),

('fact','relation','Hvem var Kristen Skjern gift med inden Elisabeth?',
 'Iben Skjold Hansen',
 '["Iben Skjold Hansen","Elisabeth Friis","Gitte Graa","Maude Varnæs"]',
 NULL,NULL),

('fact','relation','Hvem er Mads og Ingeborgs fælles biologiske søn?',
 'Erik',
 '["Erik","Daniel","Ulrik","Mogens"]',
 NULL,NULL),

('fact','relation','Hvem er Mads Skjerns bror?',
 'Kristen Skjern',
 '["Kristen Skjern","Jørgen Varnæs","Hans Christian Varnæs","Skjold Hansen"]',
 NULL,NULL),

('fact','relation','Hvem er Gitte Graas far?',
 'Senior Graa – storaktionær i Graas Klædefabrik',
 '["Senior Graa – storaktionær i Graas Klædefabrik","Baron von Rydtger","Borgmester Sejersen","Oberst Hachel"]',
 NULL,NULL),

('fact','relation','Hvad er Elisabeth Friis'' stilling hos familien Varnæs inden 1931?',
 'Husholderske',
 '["Husholderske","Stuepige","Kokkepige","Governess"]',
 NULL,NULL),

('fact','relation','Hvad er Laura Sørensens stilling hos familien Varnæs?',
 'Kokkepige',
 '["Kokkepige","Stuepige","Husholderske","Barnepige"]',
 NULL,NULL),

('fact','relation','Hvem gifter Boldt sig med i 1946?',
 'Ada – den nye bestyrerinde for Jernbane Hotellet',
 '["Ada – den nye bestyrerinde for Jernbane Hotellet","Agnes","Ulla","Misse"]',
 NULL,NULL),

('fact','relation','Hvad er Skjold Hansens hustrus navn?',
 'Musse',
 '["Musse","Maude","Ingeborg","Agnes"]',
 NULL,NULL),

('fact','relation','Hvad er Skjold Hansens datters navn?',
 'Iben',
 '["Iben","Ellen","Regitze","Helle"]',
 NULL,NULL);

-- ============================================================
-- LOKATIONER (locations)
-- ============================================================
INSERT INTO questions (type, category, question, answer, options, episode, ep_title) VALUES

('fact','lokation','Hvad hedder den fiktive by, Matador foregår i?',
 'Korsbæk',
 '["Korsbæk","Vejle","Silkeborg","Horsens"]',
 NULL,NULL),

('fact','lokation','Hvad hedder Mads Skjerns allerførste butik i Korsbæk?',
 'Tøjhuset',
 '["Tøjhuset","Skjerns Manufaktur","Damernes Magasin","Korsbæk Mode"]',
 1,'Den rejsende'),

('fact','lokation','Hvad hedder Mads'' butik fra 1933?',
 'Skjerns Magasin',
 '["Skjerns Magasin","Tøjhuset","Mads'' Magasin","Korsbæk Varehus"]',
 NULL,NULL),

('fact','lokation','Hvad hedder banken i Korsbæk?',
 'Korsbæk Bank',
 '["Korsbæk Bank","Jyllandsbanken","Nationalbanken","Korsbæk Sparekasse"]',
 NULL,NULL),

('fact','lokation','Hvad hedder den bank Mads og Kristen åbner i 1932?',
 'Omegnsbanken',
 '["Omegnsbanken","Skjerns Bank","Andersen-Skjerns Bank","Korsbæk Handelsbank"]',
 NULL,NULL),

('fact','lokation','Hvilken type sted er Jernbanerestauranten i serien?',
 'Et samlingssted for byens borgere ved stationen',
 '["Et samlingssted for byens borgere ved stationen","En fin restaurant kun for borgerskabet","En arbejderkantine","Et logi for rejsende"]',
 NULL,NULL),

('fact','lokation','Hvem driver Korsbæk Bank ved seriens begyndelse?',
 'Hans Christian Varnæs',
 '["Hans Christian Varnæs","Skjold Hansen","Mads Andersen-Skjern","Jørgen Varnæs"]',
 NULL,NULL),

('fact','lokation','I hvilken dansk region er den fiktive by Korsbæk placeret?',
 'Jylland',
 '["Jylland","Sjælland","Fyn","Bornholm"]',
 NULL,NULL),

('fact','lokation','Hvad hedder restauranten, hvor Mads ankommer i ep.1?',
 'Jernbanerestauranten',
 '["Jernbanerestauranten","Hotellets spisestue","Kongens Kro","Stationskroen"]',
 1,'Den rejsende'),

('fact','lokation','Hvad hedder Albert Arnesens forretning?',
 'Damernes Magasin',
 '["Damernes Magasin","Arnesens Manufaktur","Korsbæk Mode","Modehuset Arnesen"]',
 NULL,NULL),

('fact','lokation','I hvilken del af Korsbæk bor borgerskabet (Varnæs, Skjern)?',
 'I villakvarteret',
 '["I villakvarteret","I arbejderkvarteret","Ved havnen","Ved jernbanegaden"]',
 NULL,NULL),

('fact','lokation','Hvad hedder Katrine og Olufs husmandssted?',
 'Korsbæk Huse',
 '["Korsbæk Huse","Korsbæk Gård","Larsensminde","Havgaarden"]',
 NULL,NULL),

('fact','lokation','Hvad hedder Baron von Rydtgers gods?',
 'Brydesø Slot',
 '["Brydesø Slot","Varnæsgaard","Korsbæk Gods","Holmegaard"]',
 NULL,NULL),

('fact','lokation','Hvad hedder Violet Vinters virksomhed?',
 'Danseskolen',
 '["Danseskolen","Pianoundervisning","Sangskolen","Violinskolen"]',
 NULL,NULL),

('fact','lokation','Hvad omdøbes Jernbane Hotellet til, da Boldt og Ada overtager?',
 'Rosenhaven',
 '["Rosenhaven","Korsbæk Kro","Stationshotellet","Jernbanepavillonen"]',
 NULL,NULL),

('fact','lokation','Hvad hedder det sted, Mads Skjern køber et sommerhus i 1931?',
 'Fedet',
 '["Fedet","Skagen","Hornbæk","Tisvildeleje"]',
 NULL,NULL),

('fact','lokation','Hvad hedder den skole Vicki Hachel begynder at undervise på i 1939?',
 'Den private skole i Korsbæk',
 '["Den private skole i Korsbæk","Korsbæk Realskole","Den tekniske skole","Kommuneskolen"]',
 NULL,NULL),

('fact','lokation','Hvad hedder det gods, Ellen Skjern lærer husholdning på i 1942?',
 'Brydesø Slot',
 '["Brydesø Slot","Havgaarden","Korsbæk Huse","Rydtgers Gods"]',
 NULL,NULL),

('fact','lokation','Hvor sender Hans Christian Gitte Graa hen for at holde hende væk fra Jørgen?',
 'Amerika – på luksuslineren Queen Mary',
 '["Amerika – på luksuslineren Queen Mary","Sverige","England","Paris"]',
 NULL,NULL),

('fact','lokation','Hvad hedder parken, borgmester Sejersen tager initiativ til i 1940?',
 'Korsbæk Folkepark ved Varpemark Huse',
 '["Korsbæk Folkepark ved Varpemark Huse","Havneparken","Stationsparken","Fru Møghes Mindelund"]',
 NULL,NULL);

-- ============================================================
-- BILLEDE-SPØRGSMÅL – gæt karakteren fra illustrationen
-- Illustrationer fra matadoronline.dk (© DR / matadoronline.dk)
-- ============================================================
-- ── BILLEDE: Gæt karakteren ud fra et rigtigt skuespiller-foto (Wikipedia) ──
INSERT INTO questions (type, category, question, answer, options, image_url) VALUES

('fact','billede','Hvilken karakter spilles af denne skuespiller?',
 'Mads Skjern',
 '["Mads Skjern","Hans Christian Varnæs","Jørgen Varnæs","Kristen Skjern"]',
 'https://upload.wikimedia.org/wikipedia/commons/0/0c/J%C3%B8rgen_Buckh%C3%B8j.jpg'),

('fact','billede','Hvilken karakter spilles af denne skuespiller?',
 'Ingeborg Skjern',
 '["Ingeborg Skjern","Agnes Jensen","Maude Varnæs","Elisabeth Friis"]',
 'https://upload.wikimedia.org/wikipedia/commons/e/eb/20230412_Ghita_N%C3%B8rby.jpg'),

('fact','billede','Hvilken karakter spilles af denne skuespiller?',
 'Maude Varnæs',
 '["Maude Varnæs","Ingeborg Skjern","Agnes Jensen","Elisabeth Friis"]',
 'https://upload.wikimedia.org/wikipedia/commons/8/8b/Malene_Schwartz%2C_actor.jpg'),

('fact','billede','Hvilken karakter spilles af denne skuespiller?',
 'Hans Christian Varnæs',
 '["Hans Christian Varnæs","Jørgen Varnæs","Mads Skjern","Skjold Hansen"]',
 'https://upload.wikimedia.org/wikipedia/commons/6/6e/Holger_Juul_Hansen_%28skuespiller%29.jpg'),

('fact','billede','Hvilken karakter spilles af denne skuespiller?',
 'Herbert Schmidt',
 '["Herbert Schmidt","Rudolf Schwann","Doktor Hansen","Jørgen Varnæs"]',
 'https://upload.wikimedia.org/wikipedia/commons/0/05/Paul_H%C3%BCttel_%28skuespiller%29.jpg');

-- ── SKUESPILLERNE: Gæt skuespillernavnet ud fra karakteren ──────────────────
INSERT INTO questions (type, category, question, answer, options, image_url) VALUES

('fact','skuespiller','Hvem spiller Mads Skjern i Matador?',
 'Jørgen Buckhøj',
 '["Jørgen Buckhøj","Bent Mejding","Kurt Ravn","Holger Juul Hansen"]',
 NULL),

('fact','skuespiller','Hvem spiller Ingeborg Skjern i Matador?',
 'Ghita Nørby',
 '["Ghita Nørby","Malene Schwartz","Helle Virkner","Kirsten Olesen"]',
 NULL),

('fact','skuespiller','Hvem spiller Røde (Lauritz Jensen) i Matador?',
 'Kurt Ravn',
 '["Kurt Ravn","Jørgen Buckhøj","Axel Strøbye","Paul Hüttel"]',
 NULL),

('fact','skuespiller','Hvem spiller Maude Varnæs i Matador?',
 'Malene Schwartz',
 '["Malene Schwartz","Ghita Nørby","Helle Virkner","Karin Nellemose"]',
 NULL),

('fact','skuespiller','Hvem spiller Hans Christian Varnæs i Matador?',
 'Holger Juul Hansen',
 '["Holger Juul Hansen","Bent Mejding","Axel Strøbye","Jørgen Buckhøj"]',
 NULL),

('fact','skuespiller','Hvem spiller Agnes Jensen i Matador?',
 'Kirsten Olesen',
 '["Kirsten Olesen","Elin Reimer","Helle Virkner","Malene Schwartz"]',
 NULL),

('fact','skuespiller','Hvem spiller Jørgen Varnæs i Matador?',
 'Bent Mejding',
 '["Bent Mejding","Holger Juul Hansen","Axel Strøbye","Jørgen Buckhøj"]',
 NULL),

('fact','skuespiller','Hvem spiller Viggo Skjold Hansen i Matador?',
 'Axel Strøbye',
 '["Axel Strøbye","Bent Mejding","Holger Juul Hansen","Paul Hüttel"]',
 NULL),

('fact','skuespiller','Hvem spiller Herbert Schmidt i Matador?',
 'Paul Hüttel',
 '["Paul Hüttel","Arthur Jensen","Axel Strøbye","Bent Mejding"]',
 NULL),

('fact','skuespiller','Hvem spiller Rudolf Schwann i Matador?',
 'Arthur Jensen',
 '["Arthur Jensen","Paul Hüttel","Axel Strøbye","Holger Juul Hansen"]',
 NULL),

('fact','skuespiller','Hvem spiller Laura Sørensen i Matador?',
 'Elin Reimer',
 '["Elin Reimer","Kirsten Olesen","Karin Nellemose","Helle Virkner"]',
 NULL),

('fact','skuespiller','Hvem spiller Misse Møghe i Matador?',
 'Karin Nellemose',
 '["Karin Nellemose","Malene Schwartz","Kirsten Olesen","Elin Reimer"]',
 NULL),

('fact','skuespiller','Hvem spiller Elisabeth Friis i Matador?',
 'Helle Virkner',
 '["Helle Virkner","Malene Schwartz","Ghita Nørby","Kirsten Olesen"]',
 NULL);
