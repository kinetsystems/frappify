import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappify/desk/desk.dart';
import 'package:frappify/settings/settings.dart';
import 'package:frappify/utils/utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DeskView extends StatefulWidget {
  const DeskView({super.key});

  @override
  State<DeskView> createState() => _DeskViewState();
}

class _DeskViewState extends State<DeskView> {
  final notificationsPopoverController = ShadPopoverController();
  final helpPopoverController = ShadPopoverController();
  final profilePopoverController = ShadPopoverController();
  int _selectedIndex = 0;
  bool _isSidebarOpen = true;
  final Set<String> _expandedWorkspaces = <String>{};

  @override
  void initState() {
    super.initState();
  }

  void _expandParentWorkspaces(DeskState state, String workspaceName) {
    // Find the parent workspace and expand it
    final workspace = state.workspaces?.firstWhere(
      (w) => w.name == workspaceName,
      orElse: () => throw StateError('Workspace not found'),
    );

    if (workspace != null &&
        workspace.parentPage != null &&
        workspace.parentPage!.isNotEmpty) {
      _expandedWorkspaces.add(workspace.parentPage!);
      // Recursively expand parent's parent
      _expandParentWorkspaces(state, workspace.parentPage!);
    }
  }

  @override
  void dispose() {
    notificationsPopoverController.dispose();
    helpPopoverController.dispose();
    profilePopoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final responsive = ResponsiveBreakpoints.of(context);

    return BlocBuilder<DeskBloc, DeskState>(
      builder: (context, state) {
        return Scaffold(
          drawer: !responsive.isDesktop
              ? _buildMobileDrawer(context, state, theme)
              : null,
          body: Column(
            children: [
              _buildAppBar(context, state, theme, responsive),
              if (state.currentWorkspace != null)
                _buildWorkspaceHeader(context, state, theme, responsive),
              _buildMainContent(context, state, theme, responsive),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileDrawer(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
  ) {
    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        if (state.workspaces != null && index < state.workspaces!.length) {
          context.read<DeskBloc>().add(
            LoadWorkspaceEvent(workspaceId: state.workspaces![index].name!),
          );
        }
        Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Text('Menu', style: theme.textTheme.h4),
        ),
        if (state.workspaces != null)
          ..._buildMobileWorkspaceItems(context, state, theme, 0)
        else
          ...List.generate(
            10,
            (index) => NavigationDrawerDestination(
              icon: const Icon(Icons.dashboard_outlined),
              label: Text('Loading...'),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildMobileWorkspaceItems(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
    int level,
  ) {
    final rootWorkspaces = state.workspaces!
        .where((w) => w.parentPage == '')
        .toList();
    final List<Widget> items = [];

    for (final workspace in rootWorkspaces) {
      final children = state.workspaces!
          .where((w) => w.parentPage == workspace.name)
          .toList();
      final isExpanded = _expandedWorkspaces.contains(workspace.name);
      final hasChildren = children.isNotEmpty;

      // Add workspace item
      items.add(
        Padding(
          padding: EdgeInsets.only(left: level * 16),
          child: ListTile(
            leading: hasChildren
                ? IconButton(
                    icon: AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.chevron_right),
                    ),
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedWorkspaces.remove(workspace.name);
                        } else {
                          _expandedWorkspaces.add(workspace.name!);
                        }
                      });
                    },
                  )
                : const Icon(Icons.dashboard_outlined),
            title: Text(workspace.label ?? 'Unknown'),
            onTap: () {
              // Expand parent workspaces when selecting a workspace
              _expandParentWorkspaces(state, workspace.name!);
              context.read<DeskBloc>().add(
                LoadWorkspaceEvent(workspaceId: workspace.name!),
              );
              Navigator.pop(context);
            },
          ),
        ),
      );

      // Add child workspaces if expanded
      if (hasChildren && isExpanded) {
        for (final child in children) {
          final childChildren = state.workspaces!
              .where((w) => w.parentPage == child.name)
              .toList();
          final childIsExpanded = _expandedWorkspaces.contains(child.name);
          final childHasChildren = childChildren.isNotEmpty;

          items.add(
            Padding(
              padding: EdgeInsets.only(left: (level + 1) * 16),
              child: ListTile(
                leading: childHasChildren
                    ? IconButton(
                        icon: AnimatedRotation(
                          turns: childIsExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.chevron_right),
                        ),
                        onPressed: () {
                          setState(() {
                            if (childIsExpanded) {
                              _expandedWorkspaces.remove(child.name);
                            } else {
                              _expandedWorkspaces.add(child.name!);
                            }
                          });
                        },
                      )
                    : const Icon(Icons.dashboard_outlined),
                title: Text(child.label ?? 'Unknown'),
                onTap: () {
                  // Expand parent workspaces when selecting a child
                  _expandParentWorkspaces(state, child.name!);
                  context.read<DeskBloc>().add(
                    LoadWorkspaceEvent(workspaceId: child.name!),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          );

          // Add grandchild workspaces if expanded (limit to 2 levels for mobile)
          if (childHasChildren && childIsExpanded && level < 1) {
            for (final grandchild in childChildren) {
              items.add(
                Padding(
                  padding: EdgeInsets.only(left: (level + 2) * 16),
                  child: ListTile(
                    leading: const Icon(Icons.dashboard_outlined),
                    title: Text(grandchild.label ?? 'Unknown'),
                    onTap: () {
                      // Expand parent workspaces when selecting a grandchild
                      _expandParentWorkspaces(state, grandchild.name!);
                      context.read<DeskBloc>().add(
                        LoadWorkspaceEvent(workspaceId: grandchild.name!),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            }
          }
        }
      }
    }

    return items;
  }

  Widget _buildAppBar(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
    ResponsiveBreakpointsData responsive,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(theme),
          _buildAppBarActions(context, state, theme, responsive),
        ],
      ),
    );
  }

  Widget _buildLogo(ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SvgPicture.asset(
        'assets/images/frappe.svg',
        colorFilter: ColorFilter.mode(
          theme.colorScheme.primary,
          BlendMode.srcIn,
        ),
        width: 30,
        height: 30,
        semanticsLabel: 'Frappe Logo',
      ),
    );
  }

  Widget _buildAppBarActions(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
    ResponsiveBreakpointsData responsive,
  ) {
    return Row(
      children: [
        _buildNotificationsPopover(context, theme),
        _buildDivider(theme),
        if (responsive.isDesktop) _buildHelpPopover(context, theme),
        _buildProfilePopover(context, state, theme),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNotificationsPopover(BuildContext context, ShadThemeData theme) {
    return ShadPopover(
      controller: notificationsPopoverController,
      popover: (context) => _buildNotificationsContent(theme),
      child: ShadButton.ghost(
        onPressed: notificationsPopoverController.toggle,
        hoverBackgroundColor: Colors.transparent,
        child: Badge(
          label: const Text('3'),
          child: Icon(
            Icons.notifications_outlined,
            color: theme.colorScheme.foreground,
            semanticLabel: 'Notifications',
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsContent(ShadThemeData theme) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Notifications', style: theme.textTheme.h4),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text('Notification ${index + 1}'),
                subtitle: Text('This is notification ${index + 1}'),
                trailing: Text(
                  '2m ago',
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.foreground,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ShadThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        Divider(height: 24, color: theme.colorScheme.foreground),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHelpPopover(BuildContext context, ShadThemeData theme) {
    return ShadPopover(
      controller: helpPopoverController,
      popover: (context) => _buildHelpContent(theme),
      child: ShadButton.ghost(
        onPressed: helpPopoverController.toggle,
        hoverBackgroundColor: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Help', style: theme.textTheme.small),
            const SizedBox(width: 8),
            Icon(Icons.arrow_downward, color: theme.colorScheme.foreground),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpContent(ShadThemeData theme) {
    final helpItems = [
      'Documentation',
      'User Forum',
      'Frappe School',
      'Report an Issue',
      'About',
      'Keyboard Shortcuts',
      'Frappe Support',
    ];

    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: helpItems
            .map(
              (item) => ShadButton.ghost(
                child: Text(
                  item,
                  style: TextStyle(color: theme.colorScheme.foreground),
                ),
                onPressed: () {},
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildProfilePopover(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
  ) {
    return ShadPopover(
      controller: profilePopoverController,
      popover: (context) => _buildProfileContent(context, theme),
      child: ShadButton.ghost(
        onPressed: profilePopoverController.toggle,
        hoverBackgroundColor: Colors.transparent,
        child: ShadAvatar(
          'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/1d24599?v=4',
          placeholder: Text(
            getInitials(state.username ?? ''),
            semanticsLabel: 'User avatar',
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ShadThemeData theme) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileMenuItem('My Profile', () {}, theme),
          _buildProfileMenuItem('My Settings', () {}, theme),
          _buildProfileMenuItem('Session Defaults', () {}, theme),
          _buildProfileMenuItem('Reload', () {}, theme),
          _buildProfileMenuItem('Apps', () {}, theme),
          _buildProfileMenuItem('Toggle Full Width', () {}, theme),
          _buildProfileMenuItem(
            'Toggle Theme',
            () => _showThemeDialog(context),
            theme,
          ),
          const Divider(),
          _buildProfileMenuItem('Logout', () {
            context.read<DeskBloc>().add(LogoutEvent(context: context));
          }, theme),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(
    String label,
    VoidCallback onPressed,
    ShadThemeData theme,
  ) {
    return ShadButton.ghost(
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: theme.colorScheme.foreground)),
    );
  }

  void _showThemeDialog(BuildContext context) {
    profilePopoverController.toggle();
    showShadDialog<void>(context: context, builder: _buildThemeDialog);
  }

  Widget _buildThemeDialog(BuildContext context) {
    final theme = ShadTheme.of(context);
    final themeOptions = [
      {
        'name': 'Frappe Light',
        'mode': ThemeMode.light,
        'icon': Icons.light_mode,
      },
      {
        'name': 'Timeless Night',
        'mode': ThemeMode.dark,
        'icon': Icons.dark_mode,
      },
      {'name': 'Automatic', 'mode': ThemeMode.system, 'icon': Icons.settings},
    ];

    return ShadDialog(
      title: const Text('Switch Theme'),
      child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: themeOptions
              .map(
                (option) => Card(
                  child: InkWell(
                    onTap: () {
                      context.read<SettingsBloc>().add(
                        ThemeChangedEvent(
                          themeMode: option['mode'] as ThemeMode,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option['name'] as String,
                            style: theme.textTheme.small,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildWorkspaceHeader(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
    ResponsiveBreakpointsData responsive,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Builder(
            builder: (context) => ShadButton.ghost(
              onPressed: () {
                if (responsive.isDesktop) {
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
              child: Icon(Icons.menu, semanticLabel: 'Toggle menu'),
            ),
          ),
          const SizedBox(width: 12),
          if (state.currentWorkspace != null)
            Text(state.currentWorkspace!, style: theme.textTheme.h4)
          else
            ShimmerContainer(width: 200, height: 24),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
    ResponsiveBreakpointsData responsive,
  ) {
    return Expanded(
      child: Row(
        children: [
          if (responsive.isDesktop) _buildDesktopSidebar(context, state, theme),
          Expanded(child: _buildContentArea(context, state, theme)),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
  ) {
    if (!_isSidebarOpen) return const SizedBox.shrink();

    return Container(
      width: 240,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.colorScheme.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.workspaces != null)
              ...state.workspaces!.where((w) => w.parentPage == '').map((
                workspace,
              ) {
                final children = state.workspaces!
                    .where((w) => w.parentPage == workspace.name)
                    .toList();
                return _buildWorkspaceItem(
                  context,
                  workspace,
                  theme,
                  state,
                  children,
                  0, // Level 0 for root workspaces
                );
              })
            else
              ...List.generate(
                30,
                (index) => _buildWorkspaceItemShimmer(theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceItem(
    BuildContext context,
    dynamic workspace,
    ShadThemeData theme,
    DeskState state,
    List<dynamic> children,
    int level,
  ) {
    final workspaceName = workspace.name?.toString();
    final isActive = workspaceName == state.currentWorkspace;
    final isExpanded = _expandedWorkspaces.contains(workspaceName);
    final hasChildren = children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(
            left: 8 + (level * 16),
            right: 8,
            top: 2,
            bottom: 2,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(color: theme.colorScheme.primary, width: 1)
                : null,
          ),
          child: ShadButton.ghost(
            onPressed: () {
              if (workspaceName != null) {
                // Expand parent workspaces when selecting a child
                _expandParentWorkspaces(state, workspaceName);
                context.read<DeskBloc>().add(
                  LoadWorkspaceEvent(workspaceId: workspaceName),
                );
              }
            },
            hoverBackgroundColor: isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indentation for child workspaces
                if (level > 0) ...[
                  SizedBox(width: (level - 1) * 16),
                  Container(
                    width: 2,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.border,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Expand/collapse button for workspaces with children
                if (hasChildren)
                  ShadButton.ghost(
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedWorkspaces.remove(workspaceName);
                        } else {
                          _expandedWorkspaces.add(workspaceName!);
                        }
                      });
                    },
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),

                // Workspace icon
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    key: ValueKey(isActive),
                    isActive ? Icons.dashboard : Icons.dashboard_outlined,
                    size: 16,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.foreground,
                  ),
                ),
                const SizedBox(width: 8),

                // Workspace label
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        workspace.label?.toString() ?? 'Unknown',
                        style: theme.textTheme.small.copyWith(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.foreground,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hasChildren && !isExpanded) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.mutedForeground,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Active indicator
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isActive
                      ? Row(
                          key: const ValueKey('active'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(key: ValueKey('inactive')),
                ),
              ],
            ),
          ),
        ),

        // Child workspaces
        if (hasChildren && isExpanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: children.map((child) {
                final childChildren = state.workspaces!
                    .where((w) => w.parentPage == child.name)
                    .toList();
                return _buildWorkspaceItem(
                  context,
                  child,
                  theme,
                  state,
                  childChildren,
                  level + 1,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildWorkspaceItemShimmer(ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ShimmerContainer(width: 40, height: 40),
          const SizedBox(width: 8),
          Expanded(child: ShimmerContainer(width: double.infinity, height: 40)),
        ],
      ),
    );
  }

  Widget _buildContentArea(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: state.isLoadingWorkspace
            ? _buildContentShimmer(theme)
            : state.workspace != null
            ? Column(
                key: ValueKey(state.currentWorkspace),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.workspace?.charts?.items?.isNotEmpty == true)
                    _buildChartsSection(context, state, theme),
                  if (state.numberCards?.isNotEmpty == true)
                    _buildNumberCardsSection(context, state, theme),
                  if (state.workspace?.shortcuts?.items?.isNotEmpty == true)
                    _buildShortcutsSection(context, state, theme),
                  if (state.workspace?.cards?.items?.isNotEmpty == true)
                    _buildCardsSection(context, state, theme),
                ],
              )
            : _buildContentShimmer(theme),
      ),
    );
  }

  Widget _buildContentShimmer(ShadThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shortcuts section shimmer
        ShimmerContainer(width: 150, height: 24),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            6,
            (index) => ShimmerContainer(width: 120, height: 60),
          ),
        ),
        const SizedBox(height: 32),
        // Cards section shimmer
        ShimmerContainer(width: 180, height: 24),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            20,
            (index) => ShimmerContainer(width: 200, height: 120),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
  ) {
    return Container();
  }

  Widget _buildNumberCardsSection(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: (state.workspace?.numberCards?.items ?? [])
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final numberCard = entry.value;
                final numberCardData = state.numberCards?[index];
                return _buildNumberCardItem(
                  numberCard.label ?? '',
                  numberCardData?.message ?? 0.0,
                  theme,
                );
              })
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNumberCardItem(
    String title,
    double amount,
    ShadThemeData theme,
  ) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.h4,
            ),
            Text(
              NumberFormat.decimalPattern().format(amount),
              style: theme.textTheme.h4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutsSection(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Shortcuts', style: theme.textTheme.h3),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: (state.workspace?.shortcuts?.items ?? [])
              .map((shortcut) => _buildShortcutCard(shortcut, theme))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildShortcutCard(dynamic shortcut, ShadThemeData theme) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              shortcut.label?.toString() ?? 'Unknown',
              style: theme.textTheme.small,
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_outward, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsSection(
    BuildContext context,
    DeskState state,
    ShadThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text('Reports & Masters', style: theme.textTheme.h3),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: (state.workspace?.cards?.items ?? [])
              .map((card) => _buildCardItem(card, theme))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCardItem(dynamic card, ShadThemeData theme) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.label?.toString() ?? 'Unknown',
              style: theme.textTheme.h4,
            ),
            const SizedBox(height: 12),
            if (card.links != null)
              ...(card.links as List<dynamic>).map(
                (link) => _buildLinkItem(link, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(dynamic link, ShadThemeData theme) {
    return InkWell(
      onTap: () {
        // Handle link tap
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.link,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                link.label?.toString() ?? 'Unknown',
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
