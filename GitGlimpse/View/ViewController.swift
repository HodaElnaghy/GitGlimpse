//
//  ViewController.swift
//  GitGlimpse
//
//  Created by Hoda Elnaghy on 10/25/23.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var repositoriesTableView: UITableView!
    
    // MARK: - Variables
    var viewModel: RepoViewModel = RepoViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repositories"
        
        if let navigationController = self.navigationController {
            let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold)]
            navigationController.navigationBar.largeTitleTextAttributes = textAttributes
            navigationController.navigationBar.prefersLargeTitles = true
        }
               
        repositoriesTableView.dataSource = self
        repositoriesTableView.delegate = self
        repositoriesTableView.register(UINib(nibName: "RepoTableViewCell", bundle: nil), forCellReuseIdentifier: "RepoTableViewCell")
        
        viewModel.repositoryDataInstance.onDataUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.repositoriesTableView.reloadData()
            }
        }
        
        viewModel.repositoryDataInstance.startLoading = { [weak self] in
            DispatchQueue.main.async {
                self?.tryAgainButton.isHidden = true
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
            }
        }
        
        viewModel.repositoryDataInstance.stopLoading = { [weak self] in
            DispatchQueue.main.async {
                self?.tryAgainButton.isHidden = true
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.repositoryDataInstance.noInternetAlert = { [weak self] in
            self?.show(messageAlert: "", message: "No internet Connection", actionTitle: "Try again", action: { _ in
                self?.viewModel.repositoryDataInstance.getRepositories(url: "https://api.github.com/repositories")
            }, actionTitle2: "Cancel", action2: { _ in
                self?.tryAgainButton.isHidden = false
            })
        }
        
        viewModel.repositoryDataInstance.noDataAlert = { [weak self] in
            self?.show(messageAlert: "", message: "Something went wrong, please try again later", actionTitle: "Try again", action: { _ in
                self?.viewModel.repositoryDataInstance.getRepositories(url: "https://api.github.com/repositories")
            }, actionTitle2: "Cancel", action2: { _ in
                self?.tryAgainButton.isHidden = false
            })
        }
        
    }
    
    @IBAction func TryAgainButtonPressed(_ sender: UIButton) {
        viewModel.repositoryDataInstance.getRepositories(url: "https://api.github.com/repositories")
    }
}

// MARK: - Table view Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.repositoryDataInstance.tableViewRepoArray?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepoTableViewCell", for: indexPath) as? RepoTableViewCell else { return UITableViewCell() }
        
        guard let repo: RepositoriesModel = viewModel.repositoryDataInstance.tableViewRepoArray?[indexPath.row] else {return UITableViewCell()}
        if let forkCount:Int = repo.forks_count {
            cell.numberOfForksLabel.text = String(forkCount)
        }
        cell.repoCreationDate.text = repo.created_at
        cell.languageLabel.text = repo.language
        cell.ownerName.text = repo.owner?.login
        cell.repoName.text = repo.name
        cell.repoCreationDate.text = viewModel.dateFomatterInstance.formatGitHubDate(repo.created_at ?? "")
        cell.languageColorImage.tintColor = viewModel.languageColors[repo.language ?? ""]
        
        if let imageUrl = URL(string: repo.owner?.avatar_url ?? "") {
            cell.ownerAvatar.kf.setImage(with: imageUrl)
        } else {
            cell.ownerAvatar.image = UIImage(systemName: "person")
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if let indexPaths = repositoriesTableView.indexPathsForVisibleRows,
               let lastIndexPath = indexPaths.last,
               lastIndexPath.row == (viewModel.repositoryDataInstance.tableViewRepoArray?.count ?? 0) - 1 {
                print("Last cell is displayed. Load more data.")
                viewModel.repositoryDataInstance.page += 1
                viewModel.repositoryDataInstance.loadMoreData()
            }
        }
    
}

// MARK: - Table view Delegate
extension ViewController: UICollectionViewDelegateFlowLayout, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

// MARK: - Functions
extension ViewController {
    
    
    
    
}
