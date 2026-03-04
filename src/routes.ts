import { createBrowserRouter } from 'react-router';
import { Layout } from './components/Layout';
import { Home } from './pages/Home';
import { Library } from './pages/Library';
import { MantraDetail } from './pages/MantraDetail';
import { CreateMantra } from './pages/CreateMantra';
import { Session } from './pages/Session';
import { Progress } from './pages/Progress';
import { Settings } from './pages/Settings';
import { NotFound } from './pages/NotFound';

export const router = createBrowserRouter([
  {
    Component: Layout,
    children: [
      { index: true, Component: Home },
      { path: 'library', Component: Library },
      { path: 'progress', Component: Progress },
      { path: 'settings', Component: Settings },
      { path: 'mantras/new', Component: CreateMantra },
      { path: 'mantras/:id', Component: MantraDetail },
      { path: 'mantras/:id/edit', Component: CreateMantra },
      { path: 'mantras/:id/session', Component: Session },
      { path: '*', Component: NotFound },
    ],
  },
]);
