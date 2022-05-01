package com.example.populationapiapp;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.RecyclerView;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonArrayRequest;
import com.android.volley.toolbox.JsonObjectRequest;

import android.graphics.Color;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import com.github.mikephil.charting.charts.BarChart;
import com.github.mikephil.charting.data.BarData;
import com.github.mikephil.charting.data.BarDataSet;
import com.github.mikephil.charting.data.BarEntry;
import com.github.mikephil.charting.utils.ColorTemplate;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    Button btn_search;
    EditText et_lowerbound, et_upperbound, et_countryname;

    BarChart bc_populationchart;
    BarData barData;
    BarDataSet barDataSet;
    ArrayList barEntries;

    PopulationReportModel reportModel;
    List<Integer> popNums;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        et_lowerbound = findViewById(R.id.et_lowerbound);
        et_upperbound = findViewById(R.id.et_upperbound);
        et_countryname = findViewById(R.id.et_countryname);
        btn_search = findViewById(R.id.btn_search);
        bc_populationchart = findViewById(R.id.bc_populationchart);

        PopulationDataService populationDataService = new PopulationDataService(MainActivity.this);

        btn_search.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                populationDataService.getCountryPopulatationNumbers(et_countryname.getText().toString(), Integer.parseInt(et_lowerbound.getText().toString()), Integer.parseInt(et_upperbound.getText().toString()), new PopulationDataService.CountryPopulationResponseListener() {
                    @Override
                    public void onError(String message) {

                    }

                    @Override
                    public void onResponse(PopulationReportModel populationReportModel) {

                        makePopulationGraph(populationReportModel);

                    }
                });

            }
        });
    }

    private void makePopulationGraph(PopulationReportModel p) {

        // x = YEARS \ y = population numbers
        barEntries = new ArrayList<>();
        popNums = p.getPopulationNumbers();
        int currentYear = Integer.parseInt(et_lowerbound.getText().toString());
        barEntries = new ArrayList<>();

        for(int i = popNums.size()-1; i > -1; i--) {
            barEntries.add(new BarEntry(currentYear, popNums.get(i)));
            currentYear++;
        }

        barDataSet = new BarDataSet(barEntries, "Population: " + et_lowerbound.getText().toString() + " - " + et_upperbound.getText().toString());
        barData = new BarData(barDataSet);
        bc_populationchart.setData(barData);
        barDataSet.setColors(ColorTemplate.JOYFUL_COLORS);
        barDataSet.setValueTextColor(Color.BLACK);
        barDataSet.setValueTextSize(15f);

    }
}