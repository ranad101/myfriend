import SwiftUI

struct ContentView: View {
    @State private var isActionSheetPresented = false
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var categories: [(UIImage, String)] = [] // Categories with images and captions
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar and "+" Button Row
                HStack {
                    TextField("Search...", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .frame(height: 40)
                        .frame(maxWidth: 300)

                    Button(action: {
                        isActionSheetPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 10)
                    .actionSheet(isPresented: $isActionSheetPresented) {
                        ActionSheet(
                            title: Text("Choose Photo Source"),
                            buttons: [
                                .default(Text("الكاميرا")) {
                                    sourceType = .camera
                                    showImagePicker = true
                                },
                                .default(Text("مكتبة الصور")) {
                                    sourceType = .photoLibrary
                                    showImagePicker = true
                                },
                                .cancel()
                            ]
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                // Main Categories Grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 15) {
                        ForEach(categories.indices, id: \.self) { index in
                            NavigationLink(destination: CategoryDetailView(categoryTitle: categories[index].1)) {
                                VStack {
                                    Image(uiImage: categories[index].0)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .cornerRadius(8)
                                    Text(categories[index].1)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                                .padding(10)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("القائمة الرئيسية")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: sourceType) { image in
                    promptForCaption(image: image)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Prompt for Caption Using UIAlertController
    private func promptForCaption(image: UIImage) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "بطاقة رئيسية", message: "ادخل اسم للبطاقة الرئيسية", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Category Name"
            }
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
                if let categoryName = alert.textFields?.first?.text, !categoryName.isEmpty {
                    categories.append((image, categoryName))
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            if let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
}

struct CategoryDetailView: View {
    let categoryTitle: String
    @State private var subItems: [(UIImage, String)] = [] // Sub-items within the category
    @State private var isActionSheetPresented = false
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack {
            Text(categoryTitle)
                .font(.largeTitle)
                .bold()
                .padding()

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 15) {
                    ForEach(subItems.indices, id: \.self) { index in
                        VStack {
                            Image(uiImage: subItems[index].0)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .cornerRadius(8)
                            Text(subItems[index].1)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .padding(5)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(.systemBackground))

            Button(action: {
                isActionSheetPresented = true
            }) {
                Text("اضف بطاقة فرعية جديدة")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .actionSheet(isPresented: $isActionSheetPresented) {
                ActionSheet(
                    title: Text("Choose Photo Source"),
                    buttons: [
                        .default(Text("الكاميرا")) {
                            sourceType = .camera
                            showImagePicker = true
                        },
                        .default(Text("مكتبة الصور")) {
                            sourceType = .photoLibrary
                            showImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: sourceType) { image in
                    promptForCaption(image: image)
                }
            }
        }
    }

    func promptForCaption(image: UIImage) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "اضف بطاقة فرعية جديدة", message: "ادخل اسم للبطاقة الفرعية", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Sub-Item Name"
            }
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
                if let subItemName = alert.textFields?.first?.text, !subItemName.isEmpty {
                    subItems.append((image, subItemName))
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            if let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImageSelected: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onImageSelected: onImageSelected)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        let onImageSelected: (UIImage) -> Void

        init(_ parent: ImagePicker, onImageSelected: @escaping (UIImage) -> Void) {
            self.parent = parent
            self.onImageSelected = onImageSelected
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
