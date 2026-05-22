library CMS347TestDataGenerator2026 version '1.0.0'

using FHIR version '4.0.1'

parameter MeasurementPeriod default Interval[@2026-01-01T00:00:00.000Z, @2027-01-01T00:00:00.000Z)
parameter NumberOfTests default 200
parameter MeasureId default 'CMS347'
parameter NumeratorTestCaseShare default 0.5
parameter NumberOfNumeratorScenarios default 4
parameter NumberOfNonNumeratorScenarios default 9

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
    'cms347-provider'

define ProviderReference:
    'Practitioner/' + ProviderId

define MaleFirstName_10:
    { 'Lucas', 'Markell', 'Leland', 'Thomas', 'Patrick', 'Johnny', 'Jude', 'Shane', 'Parker', 'Julian' }

define FemaleFirstName_10:
    { 'Lilian', 'Carrie', 'Meagan', 'Rhonda', 'Nicole', 'Jamie', 'Sara', 'Ayesha', 'Layla', 'Maeve' }

define LastNames_10:
    { 'Galvez', 'Najera', 'Hughes', 'Lane', 'Mejia', 'Robinson', 'Anderson', 'Ramirez', 'Rogers', 'Kaur' }

define RandomFirstName:
    if RandomNumberInRange(0, 1) = 0 then MaleFirstName_10[RandomNumberInRange(0, 9)] else FemaleFirstName_10[RandomNumberInRange(0, 9)]

define RandomGender:
    if RandomNumberInRange(0, 1) = 0 then 'male' else 'female'

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

define ASCVDConditionCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '10273003', '127014009' }
    }

define LDLCholesterolCode:
    Tuple {
        system: 'http://loinc.org',
        code: '13457-7'
    }

define DiabetesCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '102781000119107' }
    }

define TenYearCVDRiskCodes:
    Tuple {
        system: 'http://loinc.org',
        codes: { '99055-6', '79423-0' }
    }

define StatinTherapyCodes:
    Tuple {
        system: 'http://www.nlm.nih.gov/research/umls/rxnorm',
        codes: { '197904', '198211', '2167565' }
    }

define RhabdomyolysisCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '240131006' }
    }

define HospiceCareAmbulatoryCodes:
    Tuple {
        system: 'http://snomed.info/sct',
        codes: { '385763009' }
    }

define StatinAllergenCodes:
    Tuple {
        system: 'http://www.nlm.nih.gov/research/umls/rxnorm',
        codes: { '301542' }
    }

define FemaleAdministrativeSexCode:
    '248152002'

define MaleAdministrativeSexCode:
    '248153007'

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

define function AdministrativeSexCodeForGender(gender String):
    if gender = 'female' then FemaleAdministrativeSexCode else MaleAdministrativeSexCode

define function GetRandomDateTimeDuringMeasurementPeriod():
    start of MeasurementPeriod + ToQuantity(ToString(RandomNumberInRange(1, 330)) + ' days')

define function GetRandomDateTimeOnOrBeforeMeasurementPeriodEnd():
    end of MeasurementPeriod - ToQuantity(ToString(RandomNumberInRange(1, 365)) + ' days')

define function BuildBaseTestCase(TestCaseId String, count Integer, PatientReference String, PatientBirthDate Date):
    TestCaseId ID
        let PatientGender: RandomGender,
            PatientFirstName: RandomFirstName,
            PatientLastName: RandomLastName,
            AdultPatient: BuildPatient(TestCaseId, PatientFirstName, PatientLastName, PatientGender, PatientBirthDate, AdministrativeSexCodeForGender(PatientGender), count),
            EncounterReference: 'Encounter/' + TestCaseId + '-enc',
            RandomEncounterCodeSet: OfficeVisitCodes[RandomNumberInRange(0, Length(OfficeVisitCodes) - 1)],
            EncounterCode: RandomEncounterCodeSet.codes[RandomNumberInRange(0, Length(RandomEncounterCodeSet.codes) - 1)],
            EncounterPeriodEnd: GetRandomDateTimeDuringMeasurementPeriod(),
            EncounterPeriodStart: EncounterPeriodEnd - ToQuantity(ToString(RandomNumberInRange(0, 3)) + ' days'),
            QualifyingEncounter: BuildEncounter(TestCaseId + '-enc', 'finished', 'AMB', RandomEncounterCodeSet.system, EncounterCode, PatientReference, EncounterPeriodStart, EncounterPeriodEnd, null),
            ASCVDCode: ASCVDConditionCodes.codes[RandomNumberInRange(0, Length(ASCVDConditionCodes.codes) - 1)],
            ASCVDCondition: BuildCondition(TestCaseId + '-ascvd', ASCVDConditionCodes.system, ASCVDCode, PatientReference, EncounterReference, GetRandomDateTimeOnOrBeforeMeasurementPeriodEnd()),
            LDLObservation: BuildQuantityObservation(TestCaseId + '-ldl', 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-lab', 'laboratory', LDLCholesterolCode.system, LDLCholesterolCode.code, PatientReference, EncounterReference, EncounterPeriodEnd, 191.0, 'mg/dL', 'mg/dL'),
            DiabetesCondition: BuildCondition(TestCaseId + '-diab', DiabetesCodes.system, DiabetesCodes.codes[0], PatientReference, EncounterReference, GetRandomDateTimeOnOrBeforeMeasurementPeriodEnd()),
            CVDRiskCode: TenYearCVDRiskCodes.codes[RandomNumberInRange(0, Length(TenYearCVDRiskCodes.codes) - 1)],
            CVDRiskObservation: BuildQuantityObservation(TestCaseId + '-risk', 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation-screening-assessment', 'screening-assessment', TenYearCVDRiskCodes.system, CVDRiskCode, PatientReference, EncounterReference, EncounterPeriodEnd, 20.0, '%', '%'),
            StatinCode: StatinTherapyCodes.codes[RandomNumberInRange(0, Length(StatinTherapyCodes.codes) - 1)],
            StatinRequest: BuildMedicationRequest(TestCaseId + '-statin', 'active', 'order', StatinTherapyCodes.system, StatinCode, PatientReference, EncounterReference, EncounterPeriodEnd),
            RhabdomyolysisCondition: BuildCondition(TestCaseId + '-rhab', RhabdomyolysisCodes.system, RhabdomyolysisCodes.codes[0], PatientReference, EncounterReference, EncounterPeriodEnd),
            HospiceProcedure: BuildProcedure(TestCaseId + '-hosp', EncounterPeriodEnd, 'completed', HospiceCareAmbulatoryCodes.system, HospiceCareAmbulatoryCodes.codes[0], PatientReference, EncounterReference, EncounterPeriodEnd),
            StatinAllergy: BuildAllergyIntolerance(TestCaseId + '-algy', StatinAllergenCodes.system, StatinAllergenCodes.codes[0], PatientReference, EncounterPeriodEnd),
            StatinAdverseEvent: BuildAdverseEvent(TestCaseId + '-adv', StatinAllergenCodes.system, StatinAllergenCodes.codes[0], PatientReference, EncounterPeriodEnd)
            return
                Tuple {
                    ThePatient: AdultPatient,
                    TheQualifyingEncounter: QualifyingEncounter,
                    TheASCVDCondition: ASCVDCondition,
                    TheLDLObservation: LDLObservation,
                    TheDiabetesCondition: DiabetesCondition,
                    TheCVDRiskObservation: CVDRiskObservation,
                    TheStatinRequest: StatinRequest,
                    TheRhabdomyolysisCondition: RhabdomyolysisCondition,
                    TheHospiceProcedure: HospiceProcedure,
                    TheStatinAllergy: StatinAllergy,
                    TheStatinAdverseEvent: StatinAdverseEvent
                }

define BuildIneligibleTestCases:
    (OtherPopulationCasesForScenario(0)) C
        let TestCaseId: BuildTestCaseId('inel-age', C),
            PatientGender: RandomGender,
            PatientFirstName: RandomFirstName,
            PatientLastName: RandomLastName,
            UnderagePatient: BuildPatient(TestCaseId, PatientFirstName, PatientLastName, PatientGender, Date(RandomNumberInRange(2010, 2015), RandomMonth, RandomDay), AdministrativeSexCodeForGender(PatientGender), C)
            return { UnderagePatient }

define BuildDenominatorIP1TestCases:
    (OtherPopulationCasesForScenario(1)) C
        let TestCaseId: BuildTestCaseId('ip1-den', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1975), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheASCVDCondition }

define BuildDenominatorIP2TestCases:
    (OtherPopulationCasesForScenario(2)) C
        let TestCaseId: BuildTestCaseId('ip2-den', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1995), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheLDLObservation }

define BuildDenominatorIP3TestCases:
    (OtherPopulationCasesForScenario(3)) C
        let TestCaseId: BuildTestCaseId('ip3-den', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1980), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheDiabetesCondition }

define BuildDenominatorIP4TestCases:
    (OtherPopulationCasesForScenario(4)) C
        let TestCaseId: BuildTestCaseId('ip4-den', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1980), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheCVDRiskObservation }

define BuildNumeratorIP1TestCases:
    (NumeratorCasesForScenario(0)) C
        let TestCaseId: BuildTestCaseId('ip1-num', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1975), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheASCVDCondition } union { Result.TheStatinRequest }

define BuildNumeratorIP2TestCases:
    (NumeratorCasesForScenario(1)) C
        let TestCaseId: BuildTestCaseId('ip2-num', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1995), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheLDLObservation } union { Result.TheStatinRequest }

define BuildNumeratorIP3TestCases:
    (NumeratorCasesForScenario(2)) C
        let TestCaseId: BuildTestCaseId('ip3-num', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1980), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheDiabetesCondition } union { Result.TheStatinRequest }

define BuildNumeratorIP4TestCases:
    (NumeratorCasesForScenario(3)) C
        let TestCaseId: BuildTestCaseId('ip4-num', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1980), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheCVDRiskObservation } union { Result.TheStatinRequest }

define BuildDenominatorExclusionRhabdomyolysisTestCases:
    (OtherPopulationCasesForScenario(5)) C
        let TestCaseId: BuildTestCaseId('dex-rhab', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1975), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheASCVDCondition } union { Result.TheRhabdomyolysisCondition }

define BuildDenominatorExceptionHospiceTestCases:
    (OtherPopulationCasesForScenario(6)) C
        let TestCaseId: BuildTestCaseId('dexc-hosp', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1975), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheASCVDCondition } union { Result.TheHospiceProcedure }

define BuildDenominatorExceptionStatinAllergyTestCases:
    (OtherPopulationCasesForScenario(7)) C
        let TestCaseId: BuildTestCaseId('dexc-algy', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1975), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheASCVDCondition } union { Result.TheStatinAllergy }

define BuildDenominatorExceptionAdverseEventTestCases:
    (OtherPopulationCasesForScenario(8)) C
        let TestCaseId: BuildTestCaseId('dexc-adv', C),
            PatientReference: 'Patient/' + TestCaseId,
            Result: BuildBaseTestCase(TestCaseId, C, PatientReference, Date(RandomNumberInRange(1955, 1975), RandomMonth, RandomDay))
            return { Result.ThePatient } union { Result.TheQualifyingEncounter } union { Result.TheASCVDCondition } union { Result.TheStatinAdverseEvent }

define BuildTestCases:
    { BuildPractitioner(ProviderId) }
    union (flatten BuildIneligibleTestCases)
    union (flatten BuildDenominatorIP1TestCases)
    union (flatten BuildDenominatorIP2TestCases)
    union (flatten BuildDenominatorIP3TestCases)
    union (flatten BuildDenominatorIP4TestCases)
    union (flatten BuildNumeratorIP1TestCases)
    union (flatten BuildNumeratorIP2TestCases)
    union (flatten BuildNumeratorIP3TestCases)
    union (flatten BuildNumeratorIP4TestCases)
    union (flatten BuildDenominatorExclusionRhabdomyolysisTestCases)
    union (flatten BuildDenominatorExceptionHospiceTestCases)
    union (flatten BuildDenominatorExceptionStatinAllergyTestCases)
    union (flatten BuildDenominatorExceptionAdverseEventTestCases)

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
                when resource is FHIR.MedicationRequest then 'MedicationRequest/'
                when resource is FHIR.Procedure then 'Procedure/'
                when resource is FHIR.AllergyIntolerance then 'AllergyIntolerance/'
                when resource is FHIR.AdverseEvent then 'AdverseEvent/'
                when resource is FHIR.Practitioner then 'Practitioner/'
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
                    FHIR.string { value: 'CMS347' }
                }
            }
        }
    }

define function BuildCondition(id String, codeSystem String, codeCode String, subject String, encounterReference String, onsetDateTime DateTime):
    FHIR.Condition {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-condition-problems-health-concerns'),
        clinicalStatus: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/condition-clinical', 'active'),
        verificationStatus: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/condition-ver-status', 'confirmed'),
        category: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/condition-category', 'problem-list-item')
        },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        onset: FHIR.dateTime { value: onsetDateTime },
        recordedDate: FHIR.dateTime { value: onsetDateTime }
    }

define function BuildQuantityObservation(id String, profile String, categoryCode String, codeSystem String, codeCode String, subject String, encounterReference String, effectiveDateTime DateTime, resultValue Decimal, resultUnit String, resultCode String):
    FHIR.Observation {
        id: FHIR.id { value: id },
        meta: BuildMeta(profile),
        status: FHIR.ObservationStatus { value: 'final' },
        category: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/observation-category', categoryCode)
        },
        code: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        effective: FHIR.dateTime { value: effectiveDateTime },
        value: FHIR.Quantity {
            value: FHIR.decimal { value: resultValue },
            unit: FHIR.string { value: resultUnit },
            system: FHIR.uri { value: 'http://unitsofmeasure.org' },
            code: FHIR.code { value: resultCode }
        }
    }

define function BuildMedicationRequest(id String, status String, intent String, medicationSystem String, medicationCode String, subject String, encounterReference String, authoredOn DateTime):
    FHIR.MedicationRequest {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationrequest'),
        status: FHIR.MedicationRequestStatus { value: status },
        intent: FHIR.MedicationRequestIntent { value: intent },
        category: List<FHIR.CodeableConcept> {
            BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/medicationrequest-category', 'community')
        },
        doNotPerform: FHIR.boolean { value: false },
        medication: BuildCodeableConcept(medicationSystem, medicationCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        encounter: FHIR.Reference { reference: FHIR.string { value: encounterReference } },
        authoredOn: FHIR.dateTime { value: authoredOn },
        requester: FHIR.Reference { reference: FHIR.string { value: ProviderReference } }
    }

define function BuildAllergyIntolerance(id String, codeSystem String, codeCode String, subject String, onsetDateTime DateTime):
    FHIR.AllergyIntolerance {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-allergyintolerance'),
        clinicalStatus: BuildCodeableConcept('http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical', 'active'),
        code: BuildCodeableConcept(codeSystem, codeCode),
        patient: FHIR.Reference { reference: FHIR.string { value: subject } },
        onset: FHIR.dateTime { value: onsetDateTime },
        recordedDate: FHIR.dateTime { value: onsetDateTime }
    }

define function BuildAdverseEvent(id String, codeSystem String, codeCode String, subject String, eventDateTime DateTime):
    FHIR.AdverseEvent {
        id: FHIR.id { value: id },
        meta: BuildMeta('http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-adverseevent'),
        actuality: FHIR.AdverseEventActuality { value: 'actual' },
        event: BuildCodeableConcept(codeSystem, codeCode),
        subject: FHIR.Reference { reference: FHIR.string { value: subject } },
        date: FHIR.dateTime { value: eventDateTime }
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
