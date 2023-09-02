package com.example.demo.controller;

import com.example.demo.model.Data;
import com.example.demo.service.DataService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

public class DataControllerTest {

    @InjectMocks
    private DataController dataController;

    @Mock
    private DataService dataService;

    @BeforeEach
    public void setup() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testWriteData() {
        // Test data
        String ssn = "778-62-8144";
        String email = "test@gmail.com";
        Data testData = new Data();
        testData.setId(1L);
        testData.setSsnNumber(ssn);
        testData.setEmail(email);

        // Mock DataService behavior
        when(dataService.writeData(testData)).thenReturn(testData);

        // Perform the test
        Data response = dataController.writeData(testData);

        // Verify DataService method call
        verify(dataService, times(1)).writeData(testData);

        // Verify the response status code
//        assertEquals(HttpStatus.OK, response.getStatusCode());

        // Verify the response body
//        assertEquals(testData, response.getBody());
    }

    @Test
    public void testReadData() {
        // Test data
        Data data1 = new Data();
        data1.setId(1L);
        data1.setSsnNumber("778-62-8144");
        data1.setEmail("test@gmail.com");

        Data data2 = new Data();
        data2.setId(2L);
        data2.setSsnNumber("778-62-8145");
        data1.setEmail("test2@gmail.com");

        List<Data> testDataList = Arrays.asList(data1, data2);

        // Mock DataService behavior
        when(dataService.readData()).thenReturn(testDataList);

        // Perform the test
        List<Data> response = dataController.readData();

        // Verify DataService method call
        verify(dataService, times(1)).readData();

        // Verify the response
        assertEquals(testDataList, response);
    }
}
