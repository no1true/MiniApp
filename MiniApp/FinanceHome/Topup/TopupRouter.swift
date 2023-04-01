//
//  TopupRouter.swift
//  MiniApp
//
//  Created by no1true on 2023/03/26.
//

import ModernRIBs

protocol TopupInteractable: Interactable, AddPaymentMethodListener, EnterAmountListener, CardOnFileListener {
    var router: TopupRouting? { get set }
    var listener: TopupListener? { get set }
    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy{ get }
}

protocol TopupViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.
}

final class TopupRouter: Router<TopupInteractable>, TopupRouting {
    private var navigationControllable:NavigationControllerable?

    // TODO: Constructor inject child builder protocols to allow building children.
    private let addPaymentMethodBuildable: AddPaymentMethodBuildable
    private var addPaymentMethodRouting: Routing?
    
    private let enterAmountBuildable: EnterAmountBuildable
    private var enterAmountRouting: Routing?
    
    private let cardOnFileBuildable: CardOnFileBuildable
    private var cardOnFileRouting: Routing?
    
    init(
        interactor: TopupInteractable,
        viewController: ViewControllable,
        addPaymentMethodBuildable: AddPaymentMethodBuildable,
        enterAmountBuildable: EnterAmountBuildable,
        cardOnFileBuildable: CardOnFileBuildable
    ) {
        self.viewController = viewController
        self.addPaymentMethodBuildable = addPaymentMethodBuildable
        self.enterAmountBuildable = enterAmountBuildable
        self.cardOnFileBuildable = cardOnFileBuildable
        super.init(interactor: interactor)
        interactor.router = self
    }

    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
        if viewController.uiviewController.presentedViewController != nil, navigationControllable != nil {
            navigationControllable?.dismiss(completion: nil)
        }
    }

    func attachAddPaymentMethod(closeButtonType: DismissButtonType) {
        if addPaymentMethodRouting != nil {
            return
        }
        
        let router = addPaymentMethodBuildable.build(withListener: interactor, closeButtonType: closeButtonType)
        
        if let navigationControllable = navigationControllable {
            navigationControllable.pushViewController(router.viewControllable, animated: true)
        } else {
            presentInsideNavigation(router.viewControllable)
        }
        attachChild(router)
        addPaymentMethodRouting = router
    }
    
    func detachAddPaymentMehtod() {
        guard let router = addPaymentMethodRouting else {
            return
        }
//        dismissPresentNavigation(completion: nil)
        navigationControllable?.popViewController(animated: true)
        detachChild(router)
        addPaymentMethodRouting = nil
    }
    
    private func presentInsideNavigation(_ viewControllable: ViewControllable){
        let navigation = NavigationControllerable(root: viewControllable)
        navigation.navigationController.presentationController?.delegate = interactor.presentationDelegateProxy
        self.navigationControllable = navigation
        // View가 없기 때문에 부모로부터 온 ViewController 에 present
        viewController.present(navigation, animated: true, completion: nil)
    }
    
    private func dismissPresentNavigation(completion: (() -> Void)?) {
        if self.navigationControllable == nil {
            return
        }
        viewController.dismiss(completion: nil)
        self.navigationControllable = nil
    }
    
    func attachEnterAmount() {
        if enterAmountRouting != nil {
            return
        }
        let router = enterAmountBuildable.build(withListener: interactor)
        
        if let navigation = navigationControllable {
            navigation.setViewControllers([router.viewControllable])
            resetChildRouting()
        } else {
            presentInsideNavigation(router.viewControllable)
        }

        attachChild(router)
        enterAmountRouting = router
    }
    
    func detachEnterAmount() {
        guard let router = enterAmountRouting else {
            return
        }
        dismissPresentNavigation(completion: nil)
        detachChild(router)
        enterAmountRouting = nil
    }
    func attachCardOnFile(paymentMethods: [PaymentMethod]) {
        if cardOnFileRouting != nil {
            return
        }
        let router = cardOnFileBuildable.build(withListener: interactor, paymentMethods: paymentMethods)
        navigationControllable?.pushViewController(router.viewControllable, animated: true)
        cardOnFileRouting = router
        attachChild(router)
    }
    
    func detachCardOnFile() {
        guard let router = cardOnFileRouting else {
            return
        }
        navigationControllable?.popViewController(animated: true)
        detachChild(router)
        cardOnFileRouting = nil
    }
    
    func popToRoot() {
        navigationControllable?.popToRoot(animated: true)
        resetChildRouting()
    }
    
    private func resetChildRouting() {
        if let cardOnFileRouting = cardOnFileRouting {
            detachChild(cardOnFileRouting)
            self.cardOnFileRouting = nil
        }
        
        if let addPaymentMethodRouting = addPaymentMethodRouting {
            detachChild(addPaymentMethodRouting)
            self.addPaymentMethodRouting = nil
        }
    }
    
    private let viewController: ViewControllable
}
