//
//  ProximityResultsListView.swift
//  AtxHealthInspection
//
//  Created by Toph Matta on 11/11/24.
//

import SwiftUI


struct ProximityResultsListView: View {
    @Environment(MapViewModel.self) var viewModel
    
    let group: LocationReportGroup
    
    var body: some View {
        VStack(spacing: 10) {
            NavigationView {
                List(group.data) { data in
                    NavigationLink {
                        ProximityReportDetail(data: data)
                    } label: {
                        ProximityReportRow( data: data)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationCompactAdaptation(.none)
    }
}

struct ProximityReportRow: View {
    let data: Report
    
    var body: some View {
        HStack {
            ScoreItem(data.score)
                .padding(.trailing)
            Text(data.restaurantName)
                .font(.title3)
            Spacer()
        }
    }
}

struct ProximityReportDetail: View {
    @Environment(MapViewModel.self) var viewModel
    let data: Report
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Report History")
                .font(.title)
            ReportChart(data: viewModel.historicalReports.toPlottableData())
            Divider()
            List(viewModel.historicalReports) { result in
                HStack {
                    ScoreItem(result.score)
                    Spacer()
                    Text(result.date.toReadable())
                        .font(.title3)
                        .foregroundStyle(.onSurface)
                }
            }
        }
        .toolbarRole(.automatic)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let coord = data.coordinate {
                    Button {
                        viewModel.openInMaps(coordinate: coord, placeName: data.address)
                    } label: {
                        Text("Open in Maps")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .task {
            await viewModel.getAllReports(with: data.facilityId)
        }
        .onDisappear {
            viewModel.clearHistorical()
        }
    }
}

