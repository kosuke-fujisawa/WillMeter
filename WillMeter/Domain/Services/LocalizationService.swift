//
// LocalizationService.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

/// 多言語化キー定数
/// 階層的な命名規則によるタイプセーフなキー管理
public enum LocalizationKeys {
    public enum WillPower {
        public static let title = "willpower.title"
        public static let currentValue = "willpower.current.value"
        public static let maxValue = "willpower.max.value"
        public static let percentage = "willpower.percentage"

        public enum Status {
            public static let excellent = "willpower.status.excellent"
            public static let good = "willpower.status.good"
            public static let low = "willpower.status.low"
            public static let critical = "willpower.status.critical"
        }

        public enum Action {
            public static let consume = "willpower.action.consume"
            public static let restore = "willpower.action.restore"
            public static let reset = "willpower.action.reset"
        }
    }

    public enum UI {
        public static let appTitle = "ui.app.title"
        public static let currentState = "ui.current.state"
        public static let done = "ui.done"
        public static let errorTitle = "ui.error.title"

        public enum Accessibility {
            public static let consumeHint = "ui.accessibility.consume.hint"
            public static let restoreHint = "ui.accessibility.restore.hint"
            public static let resetHint = "ui.accessibility.reset.hint"
            public static let languageButton = "ui.accessibility.language.button"
            public static let languageButtonHint = "ui.accessibility.language.button.hint"
        }
    }

    public enum Settings {
        public static let language = "settings.language"
        public static let currentLanguage = "settings.current.language"
    }

    public enum Onboarding {
        public static let title = "onboarding.title"
        public static let description = "onboarding.description"
        public static let howToTitle = "onboarding.howto.title"
        public static let howToConsume = "onboarding.howto.consume"
        public static let howToRestore = "onboarding.howto.restore"
        public static let howToReset = "onboarding.howto.reset"
        public static let startButton = "onboarding.start.button"
    }

    public enum Recommendation {
        public static let excellent = "recommendation.excellent"
        public static let good = "recommendation.good"
        public static let low = "recommendation.low"
        public static let critical = "recommendation.critical"
    }

    public enum Error {
        public static let dataNotFound = "error.data.notfound"
        public static let saveFailed = "error.save.failed"
        public static let loadFailed = "error.load.failed"
    }
}
