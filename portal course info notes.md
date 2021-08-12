The department codes in Portal differ from Informer:

- Critical Studies is CRTSD and not CRTST
- Design Strategy is DSMBA and not DESST
- Diversity Studies is either DIVSM (Seminar) or DIVST (Studio) and not DIVRS
- Grad Wide Electives are GELCT and not under their respective departments
    + It is _almost_ true that all GELCT courses are cross-listed. There are 15 total sections that match the query `course_name LIKE 'GELCT%' AND csxl IS NULL` and of those 12 were cancelled. But the 3 that remain are genuine GELCT courses, "Outlaws: Art vs Ethics & Law" and "Art Practical: Prof of Wrtng". They date back to 2017SP and I can see that VAULT classified "Outlaws" under CURPR and "Art Practical" under VISCR.
- Interdisciplinary Studio is UDIST and not INTDS, which our course list scripts in turn have special logic to store under CRITI
- Literary & Performing Arts is LITPA, separated out from under WRLIT
- Philosophy & Critical Theory (PHCRT), Science/Math (SCIMA), & Social Science History (SSHIS) have all been broken out into independent departments from under CRTST
- Changed department codes tend to update the "subject" code in Workday data but not the Academic Unit. As a consequence, HAAVC courses still have a dept code of "VISST" and the split ETHSM/ETHST (Critical Ethnic Studies) courses have a dept code of DIVST

# Workday course data

- process new course lists
- connect old data with new?
- standardize terms?
    + here are all the semester forms: FA19, Fall_2019, 2019FA
    + here are all the section/course IDs what do they mean/which to use
"courses" links on department pages no longer retrieve all courses
because of how LITPA, SSHIS, PHCRT, SCIMA are "subjects" but not distinct departments
so WRLIT dept page courses link pulls up only WRLIT courses but not LITPA

# July 22nd, 2019 meeting with Ngoc, Althea, Michelle, Analisa

we also only need section-level data, no cancelled courses is great for us (that's
what the JSON export is)
can section_calc_id change? yes, so don't use it as identifier
it's basically just used to make URLs for Portal

does it make more sense for VAULT to have a new, separate file or to add info to existing file?
Ngoc says no, it's a lot of work to create reports for every use case
then remember what they're doing
instead find the general cases, overlap between us & portal

does academic unit ID change? e.g. AU_FYCST
sounds like we _really_ try not to change them
but there's nothing 100% stopping it

First Year Program _is not an academic unit_?!?

can we include UUIDs for object like AU or AP as well as text strings?
Ngoc doesn't want to, not clear what they are, there's a WID for each object
so it would balloon the size

we want course/section tags (apparently used at both levels rather inconsistently)

there might be multiple AUs for a single section (though this hasn't happened yet)

MZ: some objects don't have reference IDs, we can only rely on WDID
WDID changes between test, production though

we'll move to a 3-period summer in Sept. 2020 (so no until 2021)
which means we might want to consider inventing abbreviations for these
e.g. 2021SU, 2021SU1, 2021SU2

asked for August 16th deadline for new format JSON data
