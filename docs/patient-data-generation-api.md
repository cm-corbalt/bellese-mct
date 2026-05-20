# Patient Data Generator API

The MCT backend API has a `$generate-patient-data` operation that produces synthetic patient data as FHIR bundles that can be used for measure testing.

## Currently supported measures:
- CMS104: antithrombiotic treatment for ischemic stroke 
- CMS122: A1c control for diabetes

## Parameters

- `numTestCases` is the total number of patients to produce across all measure groups (numerator, denominator, denominator exclusion, etc). The minimum is 10 and the maximum is 1000. The default is 200.
- `measureRef` is the measure for which relevant patient data should be generated. The default is CMS104.

## How it works

The endpoint calls the PatientDataGeneratorService, which executes CQL that produces the data. The CQL for each measure defines patient characteristics and associated clinical history (e.g. Observation, Encounter, MedicationRequest).

For each measure, the proportion of patients in the numerator group is fixed in the CQL. The number of numerator patients is the product of this proportion and the requested number of cases, rounded to the nearest whole number. The number of patients in all other groups is derived by splitting the remainder of requested test cases evenly across the other scenarios. As a result, when the number of test cases requested is small, there is guaranteed to be patients in the numerator scenario, but not every other scenario is guaranteed representation based on the remainder distribution.