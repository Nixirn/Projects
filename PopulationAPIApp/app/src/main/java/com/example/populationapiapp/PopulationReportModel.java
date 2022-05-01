package com.example.populationapiapp;

import java.util.ArrayList;
import java.util.List;

public class PopulationReportModel {

    public List<Integer> populationNumbers = new ArrayList<>();
    public int startYear;
    public int endYear;
    public String code;

    public PopulationReportModel(List<Integer> populationNumbers, int startYear, int endYear, String code) {
        this.populationNumbers = populationNumbers;
        this.startYear = startYear;
        this.endYear = endYear;
        this.code = code;
    }

    public PopulationReportModel() { }

    @Override
    public String toString() {
        return "PopulationReportModel{" +
                "populationNumbers=" + populationNumbers +
                ", startYear=" + startYear +
                ", endYear=" + endYear +
                ", code='" + code + '\'' +
                '}';
    }

    public List<Integer> getPopulationNumbers() {
        return populationNumbers;
    }

    public void setPopulationNumbers(List<Integer> populationNumbers) {
        this.populationNumbers = populationNumbers;
    }

    public int getStartYear() {
        return startYear;
    }

    public void setStartYear(int startYear) {
        this.startYear = startYear;
    }

    public int getEndYear() {
        return endYear;
    }

    public void setEndYear(int endYear) {
        this.endYear = endYear;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }
}
