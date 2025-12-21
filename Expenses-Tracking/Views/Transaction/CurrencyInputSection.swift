//
//  CurrencyInputSection.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 06/12/25.
//

import SwiftUI
import SwiftData

struct CurrencyInputSection: View {
    @Bindable var viewModel: CurrencyViewModel
    
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        Section {
            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    currencyPickerButton
                    
                    Spacer()
                    
                    amountTextField
                }
                
                if viewModel.selectedCurrency != .vnd {
                    Divider()
                    conversionInfoView
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text(AppStrings.Transaction.currencyTitle)
        }
        .animation(.default, value: viewModel.selectedCurrency)
    }
}

extension CurrencyInputSection {
    private var currencyPickerButton: some View {
        Menu {
            Picker(AppStrings.Transaction.currencyType, selection: $viewModel.selectedCurrency) {
                ForEach(Currency.allCases) { currency in
                    Text("\(currency.flag) \(currency.id)").tag(currency)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(viewModel.selectedCurrency.flag)
                    .font(.title3)
                Text(viewModel.selectedCurrency.id)
                    .font(.headline)
                    .fontWeight(.bold)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .bold()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .clipShape(Capsule())
            .foregroundStyle(.blue)
        }
        .onChange(of: viewModel.selectedCurrency) { _, newValue in
            if newValue != .vnd {
                Task { await viewModel.fetchRate() }
            } else {
                withAnimation {
                    viewModel.resetToVND()
                }
            }
        }
    }
    
    private var amountTextField: some View {
        VStack(alignment: .trailing, spacing: 2) {
            TextField("0", value: $viewModel.foreignAmount, format: .number)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())
                .focused(isFocused)
                    
            if viewModel.selectedCurrency != .vnd {
                Text(viewModel.selectedCurrency.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var conversionInfoView: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(AppStrings.Transaction.exchangeRate)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if viewModel.isManualRate {
                        TextField("0", value: $viewModel.exchangeRate, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .padding(4)
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(4)
                    } else {
                        if viewModel.isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("1 \(viewModel.selectedCurrency.id) = \(viewModel.exchangeRate.formatted(.currency(code: "VND").precision(.fractionLength(0))))")
                                .fontWeight(.medium)
                        }
                        
                        Button(action: {Task { await viewModel.fetchRate() } }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
                
                HStack {
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption2)
                            .foregroundStyle(.red)
                    } else if let date = viewModel.lastUpdated {
                        Text("Cập nhật: \(date.formatted(date: .omitted, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(viewModel.isManualRate ? AppStrings.Transaction.useAPI : AppStrings.Transaction.manual) {
                        viewModel.toggleManualRate()
                    }
                    .font(.caption2)
                    .buttonStyle(.borderless)
                }
            }
            
            HStack {
                Text(AppStrings.Transaction.resultVND)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(viewModel.finalVNDAmount.formatted(.currency(code: AppStrings.General.currencyVND)))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    @FocusState var focus: Bool
    return CurrencyInputSection(viewModel: CurrencyViewModel(service: MockCurrencyService()), isFocused: $focus)
        .padding()
}
