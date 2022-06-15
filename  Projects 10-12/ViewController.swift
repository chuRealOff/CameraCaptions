//
//  ViewController.swift
//   Projects 10-12
//
//  Created by CHURILOV DMITRIY on 08.06.2022.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photoAlbum = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Photo Album"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addPhoto))
        
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "photoes") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                photoAlbum = try jsonDecoder.decode([Photo].self, from: savedData)
            } catch {
                print("Failed to load people")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoAlbum.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Photo", for: indexPath) as? PhotoCell else {
            fatalError("Unable to retrieve a PhotoCell.")
        }
        
        let photo = photoAlbum[indexPath.row]
        
        cell.name.text = photo.name
        
        let path = getDocumentsDirectory().appendingPathComponent(photo.image)
        cell.image_View.image = UIImage(contentsOfFile: path.path)
        
//        cell.imageView?.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
//            cell.imageView?.layer.borderWidth = 2
//            cell.imageView?.layer.cornerRadius = 3
//            cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photoAlbum[indexPath.row]
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = photo.image
            vc.caption = photo.name
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        dismiss(animated: true)
        
        
        let ac = UIAlertController(title: "New Photo", message: "Give it a name", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: imagePath)
            }
            
            let photo = Photo(name: newName, image: imageName)
            
            self?.photoAlbum.append(photo)
            
            self?.save()
            self?.tableView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc func addPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(photoAlbum) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "photoes")
        } else {
            print("Failed to save people")
        }
    }
    
}


