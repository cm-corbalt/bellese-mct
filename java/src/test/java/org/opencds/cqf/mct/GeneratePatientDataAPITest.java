package org.opencds.cqf.mct;

import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.IntegerType;
import org.hl7.fhir.r4.model.StringType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.opencds.cqf.mct.api.GeneratePatientDataAPI;
import org.opencds.cqf.mct.service.PatientDataGeneratorService;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;

class GeneratePatientDataAPITest {

    private StubPatientDataGeneratorService patientDataGeneratorService;
    private GeneratePatientDataAPI generatePatientDataAPI;
    
    @BeforeEach
    void setUp() {
        patientDataGeneratorService = new StubPatientDataGeneratorService();
        generatePatientDataAPI = new GeneratePatientDataAPI(patientDataGeneratorService);
    }

    @Test
    void generatePatientDataDefaultsMissingParameters() throws Exception {
        Bundle expectedBundle = new Bundle();
        patientDataGeneratorService.response = expectedBundle;

        Bundle actualBundle = generatePatientDataAPI.generatePatientData(null, null);

        assertSame(expectedBundle, actualBundle);
        assertEquals(200, patientDataGeneratorService.numTestCases);
        assertEquals("CMS104", patientDataGeneratorService.measureRef);
    }

    @Test
    void generatePatientDataPassesExplicitParameters() throws Exception {
        Bundle expectedBundle = new Bundle();
        patientDataGeneratorService.response = expectedBundle;

        Bundle actualBundle = generatePatientDataAPI.generatePatientData(new IntegerType(10), new StringType("CMS122"));

        assertSame(expectedBundle, actualBundle);
        assertEquals(10, patientDataGeneratorService.numTestCases);
        assertEquals("CMS122", patientDataGeneratorService.measureRef);
    }

    @Test
    void generatePatientDataPropagatesServiceException() throws Exception {
        IllegalArgumentException expectedException = new IllegalArgumentException("Invalid measure");
        patientDataGeneratorService.exception = expectedException;

        IllegalArgumentException actualException = assertThrows(
            IllegalArgumentException.class, () -> { 
                generatePatientDataAPI.generatePatientData(new IntegerType(10), new StringType("CMS999"));
            }
        );

        assertSame(expectedException, actualException);
    }

    private static class StubPatientDataGeneratorService extends PatientDataGeneratorService {
        private Integer numTestCases;
        private String measureRef;
        private Bundle response = new Bundle();
        private RuntimeException exception;

        private StubPatientDataGeneratorService() {
            super(null);
        }

        @Override
        public Bundle generatePatientData(Integer numTestCases, String measureRef)
                throws IOException, NoSuchMethodException {
            this.numTestCases = numTestCases;
            this.measureRef = measureRef;
            if (exception != null) {
                throw exception;
            }
            return response;
        }
    }
}
