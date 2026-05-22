library CMS125TestDataGenerator2026 version '1.0.0'

using FHIR version '4.0.1'

parameter MeasurementPeriod default Interval[@2026-01-01T00:00:00.000Z, @2027-01-01T00:00:00.000Z)
parameter NumberOfTests default 200
parameter MeasureId default 'CMS125'
parameter NumeratorTestCaseShare default 0.5
parameter NumberOfNumeratorScenarios default 2
parameter NumberOfNonNumeratorScenarios default 7

define function GetNumberOfTestCasesList(count Integer):
    if count <= 0 then ({ 0 }) emptyResult
        where false
        return emptyResult
    else (expand { Interval[ToQuantity(0), ToQuantity(count - 1)] } per ToQuantity(1)) expandResult
        return Truncate((start of expandResult).value)

define NumberOfTestCases:
    GetNumberOfTestCasesList(NumberOfTests)

define NumeratorTestCaseCount:
    Truncate(Round(Length(NumberOfTestCases) * NumeratorTestCaseShare))

define NumeratorBaseCount:
    Truncate(NumeratorTestCaseCount / NumberOfNumeratorScenarios)

define NumeratorRemainder:
    NumeratorTestCaseCount - (NumeratorBaseCount * NumberOfNumeratorScenarios)

define function NumeratorCountForScenario(scenarioIndex Integer):
    NumeratorBaseCount + (if scenarioIndex < NumeratorRemainder then 1 else 0)

define function NumeratorCasesForScenario(scenarioIndex Integer):
    GetNumberOfTestCasesList(NumeratorCountForScenario(scenarioIndex))

define OtherTestCaseCount:
    Length(NumberOfTestCases) - NumeratorTestCaseCount

define OtherPopulationBaseCount:
    Truncate(OtherTestCaseCount / NumberOfNonNumeratorScenarios)

define OtherPopulationRemainder:
    OtherTestCaseCount - (OtherPopulationBaseCount * NumberOfNonNumeratorScenarios)

define function OtherPopulationCountForScenario(scenarioIndex Integer):
    OtherPopulationBaseCount + (if scenarioIndex < OtherPopulationRemainder then 1 else 0)

define function OtherPopulationCasesForScenario(scenarioIndex Integer):
    GetNumberOfTestCasesList(OtherPopulationCountForScenario(scenarioIndex))

define function BuildTestCaseId(population String, count Integer):
    MeasureId + '-' + ToString(NumberOfTests) + 'N-' + population + '-' + ToString(count)

define function getRandomNumber() returns Decimal : external

define function RandomNumberInRange(low Integer, high Integer):
    Truncate(Round(getRandomNumber() * ( high - low ) + low))

define RandomMonth:
    RandomNumberInRange(1, 12)

define RandomDay:
    RandomNumberInRange(1, 28)

define EvaluationTimezone:
    timezoneoffset from Now()

define ProviderId:
    'cms125-provider'

define ProviderReference:
    'Practitioner/' + ProviderId

define MaleFirstName_10:
    { 'Lucas', 'Markell', 'Leland', 'Thomas', 'Patrick', 'Johnny', 'Jude', 'Shane', 'Parker', 'Julian' }

define FemaleFirstName_10:
    { 'Lilian', 'Carrie', 'Meagan', 'Rhonda', 'Nicole', 'Jamie', 'Sara', 'Ayesha', 'Layla', 'Maeve' }

define LastNames_10:
    { 'Galvez', 'Najera', 'Hughes', 'Lane', 'Mejia', 'Robinson', 'Anderson', 'Ramirez', 'Rogers', 'Kaur' }

define RandomFemaleFirstName:
    FemaleFirstName_10[RandomNumberInRange(0, 9)]

define RandomLastName:
    LastNames_10[RandomNumberInRange(0, 9)]

define OfficeVisitCodes:
    {
        Tuple {
            system: 'http://www.ama-assn.org/go/cpt',
            codes: { '99202', '99203', '99204', '99212', '99213' }
        },
        Tuple {
            system: 'http://snomed.info/sct',
            codes: { '185349003', '185463005', '185465003' }
        }
    }

define MammographyCodes:
    Tuple {
        system: 'http://loinc.org',
        codes: { '24606-6', '24604-1' }
    }

define HospiceCareAmbulatoryCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '385763009' }
    }

define BilateralMastectomyCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '22418005' }
    }

define LeftMastectomyCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '741009001' }
    }

define RightMastectomyCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '741010006' }
    }

define PalliativeCareInterventionCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '103735009' }
    }

define HousingStatusCode:
    Tuple {
        system: 'http://loinc.org',
        code: '71802-3'
    }

define LivesInNursingHomeCode:
    Tuple {
        system: 'http://snomed.info/sct',
        code: '160734000'
    }

define FemaleAdministrativeSexCode:
    '248152002'

define RaceCategoryCodes:
    {
        Tuple { raceCategoryCode: '1002-5', raceCategoryDisplay: 'American Indian or Alaska Native' },
        Tuple { raceCategoryCode: '2028-9', raceCategoryDisplay: 'Asian' },
        Tuple { raceCategoryCode: '2054-5', raceCategoryDisplay: 'Black or African American' },
        Tuple { raceCategoryCode: '2076-8', raceCategoryDisplay: 'Native Hawaiian or Other Pacific Islander' },
        Tuple { raceCategoryCode: '2106-3', raceCategoryDisplay: 'White' }
    }

define EthnicityCategoryCodes:
    {
        Tuple { ethnicityCategoryCode: '2135-1', ethnicityCategoryDisplay: 'Hispanic or Latino' },
        Tuple { ethnicityCategoryCode: '2186-5', ethnicityCategoryDisplay: 'Non Hispanic or Latino' }
    }

define function GetRandomDateTimeDuringMeasurementPeriod():
    start of MeasurementPeriod + ToQuantity(ToString(RandomNumberInRange(1, 330)) + ' days')

define function GetRandomDateTimeDuringNumeratorLookback():
    start of MeasurementPeriod - ToQuantity(ToString(RandomNumberInRange(1, 365)) + ' days')

define function GetRandomDateTimeOnOrBeforeMeasurementPeriodEnd():
    end of MeasurementPeriod - ToQuantity(ToString(RandomNumberInRange(1, 365)) + ' days')

define function BuildBaseTestCase(TestCaseId String, count Integer, PatientReference String, PatientBirthDate Date):
    TestCaseId ID
        let PatientFirstName: RandomFemaleFirstName,
            PatientLastName: RandomLastName,
            AdultPatient: BuildPatient(TestCaseId, PatientFirstName, PatientLastName, 'female', PatientBirthDate, FemaleAdministrativeSexCode, count),
            EncounterReference: 'Encounter/' + TestCaseId + '-enc',
            RandomEncounterCodeSet: OfficeVisitCodes[RandomNumberInRange(0, Length(OfficeVisitCodes) - 1)],
            EncounterCode: RandomEncounterCodeSet.codes[RandomNumberInRange(0, Length(RandomEncounterCodeSet.codes) - 1)],
            EncounterPeriodEnd: GetRandomDateTimeDuringMeasurementPeriod(),
            EncounterPeriodStart: EncounterPeriodEnd - ToQuantity(ToString(RandomNumberInRange(0, 3)) + ' days'),
            QualifyingEncounter: BuildEncounter(TestCaseId + '-enc', 'finished', 'AMB', RandomEncounterCodeSet.system, EncounterCode, PatientReference, EncounterPeriodStart, EncounterPeriodEnd, null),
            MammographyCode: MammographyCodes.codes[RandomNumberInRange(0, Length(MammographyCodes.codes) - 1)],
            MammogramInMeasurementPeriod: BuildMammographyObservation(TestCaseId + '-mam-mp', MammographyCodes.system, MammographyCode, PatientReference, EncounterReference, EncounterPeriodEnd),
            MammogramInLookback: BuildMammographyObservation(TestCaseId + '-mam-lb', MammographyCodes.system, MammographyCode, PatientReference, EncounterReference, GetRandomDateTimeDuringNumeratorLookback()),
            HospiceProcedure: BuildProcedure(TestCaseId + '-hosp', EncounterPeriodEnd, 'completed', HospiceCareAmbulatoryCodes.system, HospiceCareAmbulatoryCodes.codes[0], PatientReference, EncounterReference, Interval[EncounterPeriodStart, EncounterPeriodEnd]),
            MastectomyDate: GetRandomDateTimeOnOrBeforeMeasurementPeriodEnd(),
            BilateralMastectomyProcedure: BuildProcedure(TestCaseId + '-bi-mast', MastectomyDate, 'completed', BilateralMastectomyCodes.system, BilateralMastectomyCodes.codes[0], PatientReference, EncounterReference, MastectomyDate),
            LeftMastectomyProcedure: BuildProcedure(TestCaseId + '-l-mast', MastectomyDate, 'completed', LeftMastectomyCodes.system, LeftMastectomyCodes.codes[0], PatientReference, EncounterReference, MastectomyDate),
            RightMastectomyProcedure: BuildProcedure(TestCaseId + '-r-mast', MastectomyDate, 'completed', RightMastectomyCodes.system, RightMastectomyCodes.codes[0], PatientReference, EncounterReference, MastectomyDate),
            NursingHomeObservation: BuildScreeningAssessmentObservation(TestCaseId + '-nh', HousingStatusCode.system, HousingStatusCode.code, LivesInNursingHomeCode.system, LivesInNursingHomeCode.code, PatientReference, EncounterReference, EncounterPeriodEnd),
            PalliativeCareProcedure: BuildProcedure(TestCaseId + '-pal', EncounterPeriodEnd, 'completed', PalliativeCareInterventionCodes.system, PalliativeCareInterventionCodes.codes[0], PatientReference, EncounterReference, Interval[EncounterPeriodStart, EncounterPeriodEnd])
            return
                Tuple {
                    ThePatient: AdultPatient,
                    TheQualifyingEncounter: QualifyingEncounter,
                    TheMammogramInMeasurementPeriod: MammogramInMeasurementPeriod,
                    TheMammogramInLookback: MammogramInLookback,
                    TheHospiceProcedure: HospiceProcedure,
                    TheBilateralMastectomyProcedure: BilateralMastectomyProcedure,
                    TheLeftMastectomyProcedure: LeftMastectomyProcedure,
                    TheRightMastectomyProcedure: RightMastectomyProcedure,
                    TheNursingHomeObservation: NursingHomeObservation,
                    ThePalliativeCareProcedure: PalliativeCareProcedure
                }

define BuildIneligibleTestCases:
    (OtherPopulationCasesForScenario(0)) C
        let TestCaseId: BuildTestCaseId('inel-age', C),
            PatientFirstName: RandomFemaleFirstName,
            PatientLastName: RandomLastName,
            UnderagePatient: BuildPatient(TestCaseId, PatientFirstName, PatientLastName, 'female', Date(RandomNumberInRange(2010, 2015), RandomMonth, RandomDay), FemaleAdministrativeSexCode, C)
            return { UnderagePatient }

define BuildInInitialPopulationTestCases:
    (OtherPopulationCasesForScenario(1)) C
        let TestCaseId: BuildTestCaseId('den-no-mammo', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1965, 1984), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter }

define BuildInNumeratorStratumOneTestCases:
    (NumeratorCasesForScenario(0)) C
        let TestCaseId: BuildTestCaseId('num-s1', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1976, 1984), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheMammogramInLookback }

define BuildInNumeratorStratumTwoTestCases:
    (NumeratorCasesForScenario(1)) C
        let TestCaseId: BuildTestCaseId('num-s2', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1952, 1974), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheMammogramInMeasurementPeriod }

define BuildDenominatorExclusionHospiceProcedureTestCases:
    (OtherPopulationCasesForScenario(2)) C
        let TestCaseId: BuildTestCaseId('dex-hosp', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1952, 1974), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheHospiceProcedure }

define BuildDenominatorExclusionBilateralMastectomyProcedureTestCases:
    (OtherPopulationCasesForScenario(3)) C
        let TestCaseId: BuildTestCaseId('dex-bi-mast', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1952, 1974), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheBilateralMastectomyProcedure }

define BuildDenominatorExclusionLeftRightMastectomyProcedureTestCases:
    (OtherPopulationCasesForScenario(4)) C
        let TestCaseId: BuildTestCaseId('dex-lr-mast', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1952, 1974), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheLeftMastectomyProcedure } union { Result.TheRightMastectomyProcedure }

define BuildDenominatorExclusionNursingHomeTestCases:
    (OtherPopulationCasesForScenario(5)) C
        let TestCaseId: BuildTestCaseId('dex-nh', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1940, 1960), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheNursingHomeObservation }

define BuildDenominatorExclusionPalliativeProcedureTestCases:
    (OtherPopulationCasesForScenario(6)) C
        let TestCaseId: BuildTestCaseId('dex-pal', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1952, 1974), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.ThePalliativeCareProcedure }

define BuildTestCases:
    { BuildPractitioner(ProviderId) }
    union (flatten BuildIneligibleTestCases)
    union (flatten BuildInInitialPopulationTestCases)
    union (flatten BuildInNumeratorStratumOneTestCases)
    union (flatten BuildInNumeratorStratumTwoTestCases)
    union (flatten BuildDenominatorExclusionHospiceProcedureTestCases)
    union (flatten BuildDenominatorExclusionBilateralMastectomyProcedureTestCases)
    union (flatten BuildDenominatorExclusionLeftRightMastectomyProcedureTestCases)
    union (flatten BuildDenominatorExclusionNursingHomeTestCases)
    union (flatten BuildDenominatorExclusionPalliativeProcedureTestCases)

define TestDataGenerationResult:
    BuildBundle(BuildTestCases)

define function BuildBundle(resources List<Choice<FHIR.Resource>>):
    FHIR.Bundle {
        type: FHIR.BundleType { value: 'transaction'},
        entry: BuildBundleEntry(resources)
    }

define function BuildBundleEntry(resources List<FHIR.Resource>):
    resources resource
        let FHIRType:
            case
                when resource is FHIR.Patient then 'Patient/'
                when resource is FHIR.Encounter then 'Encounter/'
                when resource is FHIR.Condition then 'Condition/'
                when resource is FHIR.Observation then 'Observation/'
                when resource is FHIR.Practitioner then 'Practitioner/'
                when resource is FHIR.Procedure then 'Procedure/'
                else ''
            end
        return
            FHIR.Bundle.Entry {
                resource: resource,
                request: FHIR.Bundle.Entry.Request {
                    method: FHIR.HTTPVerb { value: 'PUT' },
                    url: FHIR.url { value: FHIRType + resource.id.value }
                }
            }

define function BuildMeta(profile String):
    FHIR.Meta {
        profile: List<FHIR.canonical> {
            FHIR.canonical { value: profile }
        }
    }

define function BuildCodeableConcept(system String, code String):
    FHIR.CodeableConcept {
        coding: List<FHIR.Coding> {
            BuildCoding(system, code)
        }
    }

define function BuildCoding(system String, code String):
    FHIR.Coding {
        system: FHIR.uri { value: system },
        code: FHIR.code { value: code }
    }

define function BuildCoding(system String, code String, display String):
    FHIR.Coding {
        system: FHIR.uri { value: system },
        code: FHIR.code { value: code },
        display: FHIR.string { value: display }
    }

define function BuildExtension(url String, value Choice<FHIR.base64Binary,FHIR.boolean,FHIR.canonical,FHIR.code,FHIR.date,FHIR.dateTime,FHIR.decimal,FHIR.id,FHIR.instant,FHIR.integer,FHIR.markdown,FHIR.oid,FHIR.positiveInt,FHIR.string,FHIR.time,FHIR.unsignedInt,FHIR.uri,FHIR.url,FHIR.uuid,FHIR.Address,FHIR.Age,FHIR.Annotation,FHIR.Attachment,FHIR.CodeableConcept,FHIR.Coding,FHIR.ContactPoint,FHIR.Count,FHIR.Distance,FHIR.Duration,FHIR.HumanName,FHIR.Identifier,FHIR.Money,FHIR.Period,FHIR.Quantity,FHIR.Range,FHIR.Ratio,FHIR.Reference,FHIR.SampledData,FHIR.Signature,FHIR.Timing,FHIR.ContactDetail,FHIR.Contributor,FHIR.Expression,FHIR.ParameterDefinition,FHIR.RelatedArtifact,FHIR.TriggerDefinition,FHIR.UsageContext,FHIR.Dosage,FHIR.Meta>):
    FHIR.Extension {
        url: FHIR.uri { value: url },
        value: value
    }

define function BuildPatientExtensions(raceTuple Tuple{raceCategoryCode String, raceCategoryDisplay String}, ethnicityTuple Tuple{ethnicityCategoryCode String, ethnicityCategoryDisplay String}, sexCode String):
    List<FHIR.Extension> {
        FHIR.Extension {
            url: FHIR.uri { value: 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race' },
            extension: List<FHIR.Extension> {
                FHIR.Extension {
                    url: FHIR.uri { value: 'ombCategory' },
                    value: BuildCoding('urn:oid:2.16.840.1.113883.6.238', raceTuple.raceCategoryCode, raceTuple.raceCategoryDisplay)
                },
                FHIR.Extension {
                    url: FHIR.uri { value: 'text' },
                    value: FHIR.string { value: raceTuple.raceCategoryDisplay }
                }
            }
        },
        FHIR.Extension {
            url: FHIR.uri { value: 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-sex' },
            value: FHIR.code { value: sexCode }
        },
        FHIR.Extension {
            url: FHIR.uri { value: 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity' },
            extension: List<FHIR.Extension> {
                FHIR.Extension {
                    url: FHIR.uri { value: 'ombCategory' },
                    value: BuildCoding('urn:oid:2.16.840.1.113883.6.238', ethnicityTuple.ethnicityCategoryCode, ethnicityTuple.ethnicityCategoryDisplay)
                },
                FHIR.Extension {
                    url: FHIR.uri { value: 'text' },
                    value: FHIR.string { value: ethnicityTuple.ethnicityCategoryDisplay }
                }
            }
        }
    }

define function BuildPatient(id String, firstName String, lastName String, gender String, birthDate Date, sexCode String, count Integer):
    FHIR.Patient {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient'),
        extension: BuildPatientExtensions(RaceCategoryCodes[RandomNumberInRange(0, 4)], EthnicityCategoryCodes[RandomNumberInRange(0, 1)], sexCode),
        identifier: List<FHIR.Identifier> {
            FHIR.Identifier {
                system: FHIR.uri { value: 'http://example.org/mct/patient-id' },
                value: FHIR.string { value: id }
            }
        },
        name: List<FHIR.HumanName> {
            FHIR.HumanName {
                use: FHIR.NameUse { value: 'official' },
                family: FHIR.string { value: lastName },
                given: List<FHIR.string> {
                    FHIR.string { value: firstName }
                }
            }
        },
        telecom: List<FHIR.ContactPoint> {
            FHIR.ContactPoint {
                system: FHIR.ContactPointSystem { value: 'email' },
                value: FHIR.string { value: firstName + '.' + lastName + '@example.org' },
                use: FHIR.ContactPointUse { value: 'home' }
            }
        },
        gender: FHIR.AdministrativeGender { value: gender },
        birthDate: FHIR.date { value: birthDate },
        deceased: FHIR.boolean { value: false },
        address: List<FHIR.Address> {
            FHIR.Address {
                line: List<FHIR.string> {
                    FHIR.string { value: ToString(count) + ' Test Data Lane' }
                },
                city: FHIR.string { value: 'Testville' },
                state: FHIR.string { value: 'MD' },
                postalCode: FHIR.string { value: '209' + ToString(RandomNumberInRange(10, 99)) },
                period: FHIR.Period {
                    start: FHIR.dateTime { value: start of MeasurementPeriod },
                    end: FHIR.dateTime { value: end of MeasurementPeriod }
                }
            }
        },
        communication: List<FHIR.Patient.Communication> {
            FHIR.Patient.Communication {
                language: BuildCodeableConcept('urn:ietf:bcp:47', 'en-US')
            }
        }
    }

define function BuildEncounter(id String, status String, classCode String, typeSystem String, typeCode String, subject String, periodStart DateTime, periodEnd DateTime, diagnosisReference String):
    FHIR.Encounter {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter'),
        status: FHIR.EncounterStatus { value: status },
        class: BuildCoding('http://terminology.hl7.org/CodeSystem/v3-ActCode', classCode),
        type: List<FHIR.CodeableConcept> {
            BuildCodeableConcept(typeSystem, typeCode)
        },
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        period: FHIR.Period { start: FHIR.dateTime { value: periodStart }, end: FHIR.dateTime { value: periodEnd } },
        diagnosis: if diagnosisReference is not null
            then List<FHIR.Encounter.Diagnosis> {
                FHIR.Encounter.Diagnosis {
                    condition: FHIR.Reference { reference: FHIR.string { value: diagnosisReference } },
                    rank: FHIR.positiveInt { value: 1 }
                }
            }
            else null
    }

define function BuildPractitioner(id String):
    FHIR.Practitioner {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-practitioner'),
        identifier: List<FHIR.Identifier> {
            FHIR.Identifier {
                system: FHIR.uri { value: 'http://hl7.org/fhir/sid/us-npi' },
                value: FHIR.string { value: '9999999999' }
            }
        },
        active: FHIR.boolean { value: true },
        name: List<FHIR.HumanName> {
            FHIR.HumanName {
                use: FHIR.NameUse { value: 'official' },
                family: FHIR.string { value: 'TestProvider' },
                given: List<FHIR.string> {
                    FHIR.string { value: 'CMS125' }
                }
            }
        }
    }

define function BuildMammographyObservation(id String, codeSystem String, codeCode String, subject String, encounterReference String, effectiveDateTime DateTime):
    FHIR.Observation {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-clinical-result'),
        status: FHIR.ObservationStatus { value: 'final' },
        category: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/observation-category', 'imaging')
        },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        effective: FHIR.dateTime { value: effectiveDateTime }
    }

define function BuildScreeningAssessmentObservation(id String, codeSystem String, codeCode String, valueSystem String, valueCode String, subject String, encounterReference String, effectiveDateTime DateTime):
    FHIR.Observation {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-screening-assessment'),
        status: FHIR.ObservationStatus { value: 'final' },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        effective: FHIR.dateTime { value: effectiveDateTime },
        value: BuildCodeableConcept(valueSystem, valueCode)
    }

define function BuildProcedure(id String, recorded DateTime, status String, codeSystem String, codeCode String, subject String, encounterReference String, performed Choice<DateTime, Interval<DateTime>>):
    FHIR.Procedure {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-procedure'),
        extension: List<FHIR.Extension> {
            BuildExtension('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-recorded', FHIR.dateTime{ value: recorded })
        },
        status: FHIR.ProcedureStatus { value: status },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        performed:
            if performed is DateTime then FHIR.dateTime { value: performed }
            else FHIR.Period { start: FHIR.dateTime { value: start of performed }, end: FHIR.dateTime { value: end of performed } }
    }
