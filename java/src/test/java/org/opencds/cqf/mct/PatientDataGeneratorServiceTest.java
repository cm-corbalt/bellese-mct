package org.opencds.cqf.mct;

import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.AdverseEvent;
import org.hl7.fhir.r4.model.AllergyIntolerance;
import org.hl7.fhir.r4.model.Condition;
import org.hl7.fhir.r4.model.Encounter;
import org.hl7.fhir.r4.model.Group;
import org.hl7.fhir.r4.model.MedicationRequest;
import org.hl7.fhir.r4.model.Observation;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.Practitioner;
import org.hl7.fhir.r4.model.Procedure;
import org.hl7.fhir.r4.model.Resource;
import org.junit.jupiter.api.Test;
import org.opencds.cqf.cql.engine.data.CompositeDataProvider;
import org.opencds.cqf.cql.engine.data.DataProvider;
import org.opencds.cqf.cql.engine.fhir.model.R4FhirModelResolver;
import org.opencds.cqf.mct.service.PatientDataGeneratorService;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PatientDataGeneratorServiceTest {

   @Test
   void cms104GeneratedPatientCountMatchesRequestedCount() throws IOException, NoSuchMethodException {
      PatientDataGeneratorService service = new PatientDataGeneratorService(emptyDataProvider());

      for (Integer requestedCount : List.of(10, 11, 200, 201)) {
         Bundle result = service.generatePatientData(requestedCount, "CMS104");

         assertEquals(requestedCount.longValue(), countResources(result, Patient.class));
         Group generatedPatients = findGeneratedPatientsGroup(result);
         assertNotNull(generatedPatients);
         assertEquals(requestedCount.intValue(), generatedPatients.getQuantity());
      }
   }

   @Test
   void cms125GeneratedPatientDataIncludesExpectedResources() throws IOException, NoSuchMethodException {
      PatientDataGeneratorService service = new PatientDataGeneratorService(emptyDataProvider());
      Integer requestedCount = 20;

      Bundle result = service.generatePatientData(requestedCount, "CMS125");

      assertEquals(requestedCount.longValue(), countResources(result, Patient.class));
      assertTrue(countResources(result, Encounter.class) > 0);
      assertTrue(countResources(result, Observation.class) > 0);
      assertTrue(countResources(result, Procedure.class) > 0);
      assertTrue(countResources(result, Practitioner.class) > 0);
      assertGeneratedResourceIdsAreWithinFhirLimit(result);

      Group generatedPatients = findGeneratedPatientsGroup(result);
      assertNotNull(generatedPatients);
      assertEquals(requestedCount.intValue(), generatedPatients.getQuantity());
   }

   @Test
   void cms347GeneratedPatientDataIncludesExpectedResources() throws IOException, NoSuchMethodException {
      PatientDataGeneratorService service = new PatientDataGeneratorService(emptyDataProvider());
      Integer requestedCount = 20;

      Bundle result = service.generatePatientData(requestedCount, "CMS347");

      assertEquals(requestedCount.longValue(), countResources(result, Patient.class));
      assertTrue(countResources(result, Encounter.class) > 0);
      assertTrue(countResources(result, Condition.class) > 0);
      assertTrue(countResources(result, Observation.class) > 0);
      assertTrue(countResources(result, MedicationRequest.class) > 0);
      assertTrue(countResources(result, Procedure.class) > 0);
      assertTrue(countResources(result, AllergyIntolerance.class) > 0);
      assertTrue(countResources(result, AdverseEvent.class) > 0);
      assertTrue(countResources(result, Practitioner.class) > 0);
      assertGeneratedResourceIdsAreWithinFhirLimit(result);

      Group generatedPatients = findGeneratedPatientsGroup(result);
      assertNotNull(generatedPatients);
      assertEquals(requestedCount.intValue(), generatedPatients.getQuantity());
   }

   private long countResources(Bundle bundle, Class<? extends Resource> resourceType) {
      return bundle.getEntry().stream()
              .map(Bundle.BundleEntryComponent::getResource)
              .filter(resourceType::isInstance)
              .count();
   }

   private Group findGeneratedPatientsGroup(Bundle bundle) {
      return bundle.getEntry().stream()
              .map(Bundle.BundleEntryComponent::getResource)
              .filter(Group.class::isInstance)
              .map(Group.class::cast)
              .filter(group -> "Generated patients".equals(group.getName()))
              .findFirst()
              .orElse(null);
   }

   private void assertGeneratedResourceIdsAreWithinFhirLimit(Bundle bundle) {
      bundle.getEntry().stream()
              .map(Bundle.BundleEntryComponent::getResource)
              .filter(resource -> resource.getIdElement() != null)
              .forEach(resource -> {
                 String id = resource.getIdElement().getIdPart();
                 assertTrue(id.length() <= 64, () -> "Resource id exceeds 64 characters: " + id);
              });
   }

   private DataProvider emptyDataProvider() {
      return new CompositeDataProvider(new R4FhirModelResolver(),
              (context, contextPath, contextValue, dataType, templateId, codePath, codes,
               valueSet, datePath, dateLowPath, dateHighPath, dateRange) -> Collections.emptyList());
   }
}
