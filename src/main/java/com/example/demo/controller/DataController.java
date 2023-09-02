package com.example.demo.controller;

import com.example.demo.model.Data;
import com.example.demo.service.DataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api")
public class DataController {
    private final DataService dataService;

    @Autowired
    public DataController(DataService dataService) {
        this.dataService = dataService;
    }

    @PostMapping("/write")
    public Data writeData(@Valid @RequestBody Data data) {
        return dataService.writeData(data);
    }

    @GetMapping("/read")
    public List<Data> readData() {
        return dataService.readData();
    }
}
