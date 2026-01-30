package main

import (
	"context"
	"encoding/json"
	"log"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// Request/Response models
type CalculationRequest struct {
	PostalCode      string  `json:"postalCode"`
	SystemSizeKW    float64 `json:"systemSizeKw"`
	RoofArea        float64 `json:"roofArea"`
	ElectricityRate float64 `json:"electricityRate"`
	Latitude        float64 `json:"latitude"`
	Longitude       float64 `json:"longitude"`
}

type CalculationResult struct {
	AnnualProduction   float64            `json:"annualProduction"`
	MonthlySavings     float64            `json:"monthlySavings"`
	AnnualSavings      float64            `json:"annualSavings"`
	PaybackYears       float64            `json:"paybackYears"`
	TotalSavings25Year float64            `json:"totalSavings25Year"`
	CO2OffsetKg        float64            `json:"co2OffsetKg"`
	TreesEquivalent    int                `json:"treesEquivalent"`
	SystemCost         float64            `json:"systemCost"`
	NetCost            float64            `json:"netCost"`
	ROIPercent         float64            `json:"roiPercent"`
	Irradiance         float64            `json:"irradiance"`
	PeakSunHours       float64            `json:"peakSunHours"`
	ClimateZone        string             `json:"climateZone"`
	MonthlyGeneration  map[string]float64 `json:"monthlyGeneration"`
}

type HealthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
	Version string `json:"version"`
}

// CORS headers for all responses
func corsHeaders() map[string]string {
	return map[string]string{
		"Access-Control-Allow-Origin":  "*",
		"Access-Control-Allow-Methods": "GET, POST, OPTIONS",
		"Access-Control-Allow-Headers": "Content-Type, Authorization",
		"Content-Type":                 "application/json",
	}
}

// Calculate ROI based on location and system parameters
func calculateROI(req CalculationRequest) CalculationResult {
	// Determine irradiance based on latitude
	lat := req.Latitude
	if lat == 0 {
		lat = 14.5995 // Default to Manila, Philippines
	}

	latAbs := lat
	if latAbs < 0 {
		latAbs = -latAbs
	}

	var avgIrradiance float64
	var climateZone string
	monthlyFactors := []float64{0.85, 0.90, 0.95, 1.0, 1.05, 1.08, 1.08, 1.05, 1.0, 0.95, 0.88, 0.82}

	// Climate zone detection based on latitude
	if latAbs < 23.5 {
		avgIrradiance = 5.2
		climateZone = "Tropical"
		monthlyFactors = []float64{0.96, 0.98, 1.02, 1.04, 1.0, 0.95, 0.92, 0.94, 0.98, 1.02, 1.0, 0.96}
	} else if latAbs < 35 {
		avgIrradiance = 4.8
		climateZone = "Subtropical"
		monthlyFactors = []float64{0.70, 0.80, 0.95, 1.05, 1.12, 1.18, 1.20, 1.15, 1.05, 0.90, 0.75, 0.65}
	} else if latAbs < 50 {
		avgIrradiance = 3.8
		climateZone = "Temperate"
		monthlyFactors = []float64{0.40, 0.55, 0.80, 1.0, 1.20, 1.30, 1.28, 1.15, 0.95, 0.70, 0.50, 0.35}
	} else {
		avgIrradiance = 2.8
		climateZone = "Subarctic"
		monthlyFactors = []float64{0.15, 0.35, 0.65, 1.0, 1.35, 1.50, 1.45, 1.20, 0.85, 0.50, 0.25, 0.10}
	}

	// System parameters with defaults
	systemSizeKW := req.SystemSizeKW
	if systemSizeKW <= 0 {
		systemSizeKW = 5.0
	}

	electricityRate := req.ElectricityRate
	if electricityRate <= 0 {
		electricityRate = 0.12 // $0.12/kWh default
	}

	// Production calculations
	systemLosses := 0.85 // 15% system losses
	peakSunHours := avgIrradiance
	dailyProductionKWh := systemSizeKW * peakSunHours * systemLosses
	annualProductionKWh := dailyProductionKWh * 365

	// Monthly generation breakdown
	monthlyGeneration := make(map[string]float64)
	months := []string{"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
	daysInMonth := []int{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

	for i, month := range months {
		monthlyGeneration[month] = dailyProductionKWh * float64(daysInMonth[i]) * monthlyFactors[i]
	}

	// Financial calculations
	annualSavings := annualProductionKWh * electricityRate
	monthlySavings := annualSavings / 12

	// System cost (~$2.75 per watt installed)
	costPerWatt := 2.75
	systemCost := systemSizeKW * 1000 * costPerWatt

	// Tax credit (30% federal in US)
	taxCredit := systemCost * 0.30
	netCost := systemCost - taxCredit

	// Payback period
	paybackYears := netCost / annualSavings

	// 25-year savings with degradation and rate increases
	totalSavings25Year := 0.0
	currentProduction := annualProductionKWh
	currentRate := electricityRate
	for year := 1; year <= 25; year++ {
		totalSavings25Year += currentProduction * currentRate
		currentProduction *= 0.995 // 0.5% annual degradation
		currentRate *= 1.03        // 3% annual rate increase
	}

	// ROI calculation
	roiPercent := ((totalSavings25Year - netCost) / netCost) * 100

	// Environmental impact
	co2PerKWh := 0.42 // kg CO2 per kWh
	co2OffsetKg := annualProductionKWh * co2PerKWh
	treesEquivalent := int(co2OffsetKg / 21)

	return CalculationResult{
		AnnualProduction:   annualProductionKWh,
		MonthlySavings:     monthlySavings,
		AnnualSavings:      annualSavings,
		PaybackYears:       paybackYears,
		TotalSavings25Year: totalSavings25Year,
		CO2OffsetKg:        co2OffsetKg,
		TreesEquivalent:    treesEquivalent,
		SystemCost:         systemCost,
		NetCost:            netCost,
		ROIPercent:         roiPercent,
		Irradiance:         avgIrradiance,
		PeakSunHours:       peakSunHours,
		ClimateZone:        climateZone,
		MonthlyGeneration:  monthlyGeneration,
	}
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	path := request.Path
	method := request.HTTPMethod
	headers := corsHeaders()

	// Handle CORS preflight
	if method == "OPTIONS" {
		return events.APIGatewayProxyResponse{
			StatusCode: 200,
			Headers:    headers,
			Body:       "",
		}, nil
	}

	log.Printf("[%s] %s", method, path)

	// Route handling
	switch {
	case strings.HasSuffix(path, "/health") || path == "/.netlify/functions/api/health":
		health := HealthResponse{
			Status:  "healthy",
			Service: "Apolaki Solar API",
			Version: "1.0.0",
		}
		body, _ := json.Marshal(health)
		return events.APIGatewayProxyResponse{
			StatusCode: 200,
			Headers:    headers,
			Body:       string(body),
		}, nil

	case strings.HasSuffix(path, "/calculate") || path == "/.netlify/functions/api/calculate":
		if method != "POST" {
			return events.APIGatewayProxyResponse{
				StatusCode: 405,
				Headers:    headers,
				Body:       `{"error": "Method not allowed"}`,
			}, nil
		}

		var req CalculationRequest
		if err := json.Unmarshal([]byte(request.Body), &req); err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 400,
				Headers:    headers,
				Body:       `{"error": "Invalid JSON request"}`,
			}, nil
		}

		result := calculateROI(req)
		body, _ := json.Marshal(result)
		return events.APIGatewayProxyResponse{
			StatusCode: 200,
			Headers:    headers,
			Body:       string(body),
		}, nil

	default:
		return events.APIGatewayProxyResponse{
			StatusCode: 404,
			Headers:    headers,
			Body:       `{"error": "Not found", "path": "` + path + `"}`,
		}, nil
	}
}

func main() {
	lambda.Start(handler)
}
