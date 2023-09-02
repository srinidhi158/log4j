package com.example.demo.service;

import com.example.demo.model.Data;
import com.example.demo.repository.DataRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DataService {
    private final DataRepository dataRepository;

    @Autowired
    public DataService(DataRepository dataRepository) {
        this.dataRepository = dataRepository;
    }

    public Data writeData(Data data) {
//        Data data = new Data();
//        data.setContent(ssn_number);
//        data.setEmail(email);
        return dataRepository.save(data);
    }

    public List<Data> readData() {
        return dataRepository.findAll();
    }
}
