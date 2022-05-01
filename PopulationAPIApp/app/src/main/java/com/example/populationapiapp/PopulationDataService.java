package com.example.populationapiapp;

import android.app.DownloadManager;
import android.content.Context;
import android.widget.ListView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonArrayRequest;
import com.android.volley.toolbox.JsonObjectRequest;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class PopulationDataService {

    public static final String QUERY_FOR_COUNTRY_CODE = "https://raw.githubusercontent.com/lukes/ISO-3166-Countries-with-Regional-Codes/master/all/all.json";
    public static final String QUERY_FOR_COUNTRY_POPULATION_1 = "https://api.worldbank.org/v2/countries/";
    public static final String QUERY_FOR_COUNTRY_POPULATION_2 = "/indicators/SP.POP.TOTL?per_page=1000&format=json";
    public static final int MAX_CODES = 249;

    String countryCode;
    Context context;

    public PopulationDataService(Context context) {
        this.context = context;
    }

    public interface CountryIdResponseListener {
        void onError(String message);

        void onResponse(String cityId);
    }

    public interface CountryPopulationResponseListener {
        void onError(String message);

        void onResponse(PopulationReportModel populationReportModel);
    }

    public interface CountryCodePopulationResponseListener {
        void onError(String message);

        void onResponse(PopulationReportModel populationReportModel);
    }

    public void getCountryCode(String countryName, CountryIdResponseListener countryIdResponseListener) {
        JsonArrayRequest request = new JsonArrayRequest(Request.Method.GET, QUERY_FOR_COUNTRY_CODE, null, new Response.Listener<JSONArray>() {
            @Override
            public void onResponse(JSONArray response) {

                countryCode = "";

                try {
                    for(int i = 0; i < MAX_CODES; i++) {
                        JSONObject countryInfo = response.getJSONObject(i);
                        String countryListName = countryInfo.getString("name");

                        if (countryListName.equals(countryName)) {
                            countryCode = countryInfo.getString("alpha-3");
                            break;
                        }

                    }
                } catch (JSONException jsonException) {
                    jsonException.printStackTrace();
                }

                countryIdResponseListener.onResponse(countryCode);

            }
        }, new Response.ErrorListener() {

            @Override
            public void onErrorResponse(VolleyError error) {
                countryIdResponseListener.onError("Failed to get id");
            }
        });

        MySingleton.getInstance(context).addToRequestQueue(request);
    }

    void getCountryPopulatationNumbersWithCode (String country3Code, int startYear, int endYear, CountryCodePopulationResponseListener countryCodePopulationResponseListener) {
        int yearDifference = endYear - startYear;
        PopulationReportModel populationReportModel = new PopulationReportModel();
        List<Integer> populationNums = new ArrayList<>();

        String url = QUERY_FOR_COUNTRY_POPULATION_1 + country3Code + QUERY_FOR_COUNTRY_POPULATION_2;



        JsonArrayRequest request = new JsonArrayRequest(Request.Method.GET, url, null, new Response.Listener<JSONArray>() {

            @Override
            public void onResponse(JSONArray response) {

                try {

                    JSONArray countryInfo = response.getJSONArray(1);
                    boolean endFound = false;
                    int i = 1;

                    // Find end year
                    while (!endFound) {
                        JSONObject yearInfo = countryInfo.getJSONObject(i);
                        String year = yearInfo.getString("date");

                        if (endYear == Integer.parseInt(year)) {
                            endFound = true;
                        }
                        else {
                            i++;
                        }
                    }

                    // Use count in a loop to go all the way to start year
                    // i is index of endYear

                    for(int j = i; j < ((i + yearDifference) + 1); j++) {
                        JSONObject yearInfo = countryInfo.getJSONObject(j);
                        int populationNum = yearInfo.getInt("value");

                        populationNums.add(populationNum);
                    }

                    // Set the values of the ReportModel

                    populationReportModel.setCode(country3Code);
                    populationReportModel.setPopulationNumbers(populationNums);
                    populationReportModel.setEndYear(endYear);
                    populationReportModel.setStartYear(startYear);

                    countryCodePopulationResponseListener.onResponse(populationReportModel);

                } catch (JSONException jsonException) {
                    jsonException.printStackTrace();
                }

            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Toast.makeText(context, "Failed to make population report model", Toast.LENGTH_SHORT).show();
            }
        });

        MySingleton.getInstance(context).addToRequestQueue(request);
    }

    void getCountryPopulatationNumbers(String countryName, int startYear, int endYear, CountryPopulationResponseListener countryPopulationResponseListener) {

        getCountryCode(countryName, new CountryIdResponseListener() {
            @Override
            public void onError(String message) {
                Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onResponse(String cityId) {

                getCountryPopulatationNumbersWithCode(cityId, startYear, endYear, new CountryCodePopulationResponseListener() {
                    @Override
                    public void onError(String message) {

                    }

                    @Override
                    public void onResponse(PopulationReportModel populationReportModel) {
                        countryPopulationResponseListener.onResponse(populationReportModel);
                    }
                });

            }
        });

    }
}
