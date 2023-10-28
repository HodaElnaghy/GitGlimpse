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
    @IBOutlet private weak var tryAgainButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var repositoriesTableView: UITableView!
    
    // MARK: - Variables
    private var viewModel: RepoViewModel = RepoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        observeChanges()
        
    }
    
    // MARK: - Actions
    @IBAction private func TryAgainButtonPressed(_ sender: UIButton) {
        viewModel.repositoryDataInstance.getRepositories(url: "https://api.github.com/repositories")
    }
}

// MARK: - Table view Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.repositoryDataInstance.tableViewRepoArray.count
    }
    
    private func setupCell (_ cell: RepoTableViewCell, with repo: RepositoriesModel) {
        if let forkCount:Int = repo.forksCount {
            cell.numberOfForksLabel.text = String(forkCount)
        }
        cell.repoCreationDate.text = repo.createdAt
        cell.languageLabel.text = repo.language
        cell.ownerName.text = repo.owner?.login
        cell.repoName.text = repo.name
        cell.repoCreationDate.text = viewModel.dateFomatterInstance.formatGitHubDate(repo.createdAt ?? "")
        cell.languageColorImage.tintColor = viewModel.languageColors[repo.language?.lowercased() ?? ""]
        
        if let imageUrl = URL(string: repo.owner?.avatarURL ?? "") {
            cell.ownerAvatar.kf.setImage(with: imageUrl)
        } else {
            cell.ownerAvatar.image = UIImage(systemName: "person")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepoTableViewCell", for: indexPath) as? RepoTableViewCell else { return UITableViewCell() }
        
        let repo: RepositoriesModel = viewModel.repositoryDataInstance.tableViewRepoArray[indexPath.row]
        setupCell(cell, with: repo)
        return cell
    }
    
}
// MARK: - UIScrollViewDelegate
extension ViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexPaths = repositoriesTableView.indexPathsForVisibleRows,
           let lastIndexPath = indexPaths.last,
           lastIndexPath.row == (viewModel.repositoryDataInstance.tableViewRepoArray.count ) - 1 {
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

// MARK: - Private functions
private extension ViewController {
    func setupNavigation() {
        title = "Repositories"
        if let navigationController = navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
    }
    
    func observeChanges() {
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
    
    func setupTableView() {
        repositoriesTableView.dataSource = self
        repositoriesTableView.delegate = self
        repositoriesTableView.register(UINib(nibName: "RepoTableViewCell", bundle: nil), forCellReuseIdentifier: "RepoTableViewCell")
    }
    
}

