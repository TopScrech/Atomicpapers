import ScrechKit

struct Filter: View {
    @EnvironmentObject private var vm: RootVM
    
    var body: some View {
        HStack {
            Menu {
                ForEach(Categories.allCases) { option in
                    Button(option.displayName) {
                        vm.applyFilter(option)
                    }
                    .tag(option)
                    
                    if option == .all { Divider() }
                }
            } label: {
                HStack {
                    Image(systemName: vm.filterOption == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    
                    Text(vm.filterOption.displayName)
                }
                .title3()
                .foregroundColor(.white)
                .padding(10)
#error("Conflict between ScrechKit and SwiftUI")
                .background(Capsule().fill(.blue))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(width: 160)
            }
            
#if DEBUG
            Button {
                Task { await vm.refreshImages() }
            } label: {
                Text("Debug Refresh")
            }
#endif
        }
        .padding(.bottom, 5)
    }
}

struct Filter_Previews: PreviewProvider {
    static var previews: some View {
        Filter()
            .darkSchemePreferred()
            .environmentObject(RootVM())
        
        Filter()
            .environmentObject(RootVM())
    }
}
