import Foundation
import UIKit
import WordPressShared

/// Displays a Blog's User Details
///
final class PersonViewController : UITableViewController {

    // MARK: - Public Properties

    /// Blog to which the Person belongs
    ///
    var blog : Blog!

    /// Person to be displayed
    ///
    var person : Person! {
        didSet {
            refreshInterfaceIfNeeded()
        }
    }

    /// Gravatar Image
    ///
    @IBOutlet var gravatarImageView : UIImageView! {
        didSet {
            refreshGravatarImage()
        }
    }

    /// Person's Full Name
    ///
    @IBOutlet var fullNameLabel : UILabel! {
        didSet {
            setupFullNameLabel()
            refreshFullNameLabel()
        }
    }

    /// Person's User Name
    ///
    @IBOutlet var usernameLabel : UILabel! {
        didSet {
            setupUsernameLabel()
            refreshUsernameLabel()
        }
    }

    /// Person's Role
    ///
    @IBOutlet var roleCell : UITableViewCell! {
        didSet {
            setupRoleCell()
            refreshRoleCell()
        }
    }

    /// Person's First Name
    ///
    @IBOutlet var firstNameCell : UITableViewCell! {
        didSet {
            setupFirstNameCell()
            refreshFirstNameCell()
        }
    }

    /// Person's Last Name
    ///
    @IBOutlet var lastNameCell : UITableViewCell! {
        didSet {
            setupLastNameCell()
            refreshLastNameCell()
        }
    }

    /// Person's Display Name
    ///
    @IBOutlet var displayNameCell : UITableViewCell! {
        didSet {
            setupDisplayNameCell()
            refreshDisplayNameCell()
        }
    }

    /// Nuking the User
    ///
    @IBOutlet var removeCell : UITableViewCell! {
        didSet {
            setupRemoveCell()
            refreshRemoveCell()
        }
    }



    // MARK: - View Lifecyle Methods

    override func viewDidLoad() {
        assert(person != nil)
        assert(blog != nil)

        super.viewDidLoad()

        title = person.fullName.nonEmptyString() ?? NSLocalizedString("Blog's User", comment: "Blog's User Profile. Displayed when the name is empty!")
        WPStyleGuide.configureColorsForView(view, andTableView: tableView)
    }


    // MARK: - UITableView Methods

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectSelectedRowWithAnimation(true)

        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else {
            return
        }

        switch cell {
        case roleCell:
            roleWasPressed()
        case removeCell:
            removeWasPressed()
        default:
            break
        }
    }


    // MARK: - Storyboard Methods

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let roleViewController = segue.destinationViewController as? RoleViewController else {
            return
        }

        roleViewController.blog = blog
        roleViewController.selectedRole = person.role
        roleViewController.onChange = { newRole in
            self.updateRole(newRole)
        }
    }



    // MARK: - Constants
    private let roleSegueIdentifier = "editRole"
    private let gravatarPlaceholderImage = UIImage(named: "gravatar.png")
}



// MARK: - Private Helpers: Actions
//
private extension PersonViewController {

    func roleWasPressed() {
        performSegueWithIdentifier(roleSegueIdentifier, sender: nil)
    }

    func removeWasPressed() {
// TODO: JLP May.3.2016. To be implemented as part of #5288
    }

    func updateRole(newRole: Person.Role) {
        guard let service = PeopleService(blog: blog) else {
            DDLogSwift.logError("Couldn't instantiate People Service")
            return
        }

        let updated = service.updatePerson(person, role: newRole) { (error, reloadedPerson) in
            self.person = reloadedPerson
            self.retryUpdatingRole(newRole)
        }

        // Optimistically refresh the UI
        self.person = updated
    }

    func retryUpdatingRole(newRole: Person.Role) {
        let retryTitle      = NSLocalizedString("Retry", comment: "Retry updating User's Role")
        let cancelTitle     = NSLocalizedString("Cancel", comment: "Cancel updating User's Role")
        let title           = NSLocalizedString("Sorry!", comment: "Update User Failed Title")
        let message         = NSLocalizedString("Something went wrong while updating the User's Role.", comment: "Updating Role failed error message")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alertController.addCancelActionWithTitle(cancelTitle, handler: nil)
        alertController.addDefaultActionWithTitle(retryTitle) { action in
            self.updateRole(newRole)
        }

        alertController.presentFromRootViewController()
    }
}



// MARK: - Private Helpers: Initializing Interface
//
private extension PersonViewController {

    func setupFullNameLabel() {
        fullNameLabel.font = WPStyleGuide.tableviewTextFont()
        fullNameLabel.textColor = WPStyleGuide.darkGrey()
    }

    func setupUsernameLabel() {
        usernameLabel.font = WPStyleGuide.tableviewSectionHeaderFont()
        usernameLabel.textColor = WPStyleGuide.wordPressBlue()
    }

    func setupFirstNameCell() {
        firstNameCell.textLabel?.text = NSLocalizedString("First Name", comment: "User's First Name")
        WPStyleGuide.configureTableViewCell(firstNameCell)
    }

    func setupLastNameCell() {
        lastNameCell.textLabel?.text = NSLocalizedString("Last Name", comment: "User's Last Name")
        WPStyleGuide.configureTableViewCell(lastNameCell)
    }

    func setupDisplayNameCell() {
        displayNameCell.textLabel?.text = NSLocalizedString("Display Name", comment: "User's Display Name")
        WPStyleGuide.configureTableViewCell(displayNameCell)
    }

    func setupRoleCell() {
        roleCell.textLabel?.text = NSLocalizedString("Role", comment: "User's Role")
        WPStyleGuide.configureTableViewCell(roleCell)
    }

    func setupRemoveCell() {
        removeCell.textLabel?.text = NSLocalizedString("Remove User", comment: "Remove User. Verb")
        WPStyleGuide.configureTableViewDestructiveActionCell(removeCell)
    }
}



// MARK: - Private Helpers: Refreshing Interface
//
private extension PersonViewController {

    func refreshInterfaceIfNeeded() {
        guard isViewLoaded() else {
            return
        }

        refreshGravatarImage()
        refreshFullNameLabel()
        refreshUsernameLabel()
        refreshRoleCell()
        refreshFirstNameCell()
        refreshLastNameCell()
        refreshDisplayNameCell()
        refreshRemoveCell()
    }

    func refreshGravatarImage() {
        gravatarImageView.downloadImage(person.avatarURL, placeholderImage: gravatarPlaceholderImage)
    }

    func refreshFullNameLabel() {
        fullNameLabel.text = person.fullName
    }

    func refreshUsernameLabel() {
        usernameLabel.text = "@" + person.username
    }

    func refreshFirstNameCell() {
        firstNameCell.detailTextLabel?.text = person.firstName
    }

    func refreshLastNameCell() {
        lastNameCell.detailTextLabel?.text = person.lastName
    }

    func refreshDisplayNameCell() {
        displayNameCell.detailTextLabel?.text = person.displayName
    }

    private func refreshRoleCell() {
        let enabled = isPromoteEnabled
        roleCell.detailTextLabel?.text = person.role.localizedName()
        roleCell.accessoryType = enabled ? .DisclosureIndicator : .None
        roleCell.selectionStyle = enabled ? .Gray : .None
        roleCell.userInteractionEnabled = enabled
        roleCell.detailTextLabel?.text = person.role.localizedName()
    }

    func refreshRemoveCell() {
        removeCell.hidden = !isRemoveEnabled
    }
}



// MARK: - Private Computed Properties
//
private extension PersonViewController {

    var isMyself : Bool {
        return blog.account!.userID == person.ID || blog.account!.userID == person.linkedUserID
    }

    var isPromoteEnabled : Bool {
        return blog.isUserCapableOf(.PromoteUsers) && isMyself == false
    }

    var isRemoveEnabled : Bool {
// TODO: JLP May.3.2016. To be uncommented as part of #5288
        return false

//        // Note: YES, ListUsers. Brought from Calypso's code
//        return blog.isUserCapableOf(.ListUsers) && isSomeoneElse
    }
}
